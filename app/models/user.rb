class User < ActiveRecord::Base
  audited allow_mass_assignment: true
  include PgSearch
  include Sortable
  include Util::TrimText

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :masqueradable, :omniauthable

  trimmed_fields :email

  has_and_belongs_to_many :roles, :join_table => :users_roles

  has_many :managed_markets_join, class_name: "ManagedMarket"
  #has_many :audits

  before_create do |user|
    if user.subscription_types.empty?
      Subscription.ensure_user_has_subscription_links_to_fresh_sheet_and_newsletter(user)
    end
  end

  # prefer Market.managed_by(user) over (user.admin? ? Market.all : user.managed_markets)
  has_many :managed_markets, through: :managed_markets_join, source: :market do
    def can_manage_organization?(org)
      joins(:organizations).where(organizations: {id: org.id}).exists?
    end
  end

  has_many :user_organizations

  has_many :organizations, -> {
    not_deleted.
    where(user_organizations: {enabled: true}).distinct
  }, through: :user_organizations

  has_many :organizations_including_suspended, -> {
    not_deleted.distinct
  }, through: :user_organizations, source: :organization

  has_many :suspended_organizations, -> { where(user_organizations: {enabled: false}) }, through: :user_organizations, source: :organization

  has_many :carts

  has_many :subscriptions
  has_many :subscription_types, through: :subscriptions

  attr_accessor :terms_of_service, :role_id

  validates :terms_of_service, acceptance: true, on: :create
  validates :name, presence: true, if: -> { name.present? }

  pg_search_scope :search_by_name_and_email,
                  against: {name: "A", email: "B"},
                  using: {tsearch: {prefix: true}}

  scope_accessible :sort, method: :for_sort, ignore_blank: true
  scope_accessible :search, method: :for_search, ignore_blank: true

  scope :buyers, -> { joins(:organizations).merge(Organization.buying) }
  scope :sellers, -> { joins(:organizations).merge(Organization.selling) }
  scope :confirmed, -> { where.not(confirmed_at: nil) }

  scope :in_market, ->(market) {
    market_id = case market
                when Market
                  market.id
                else
                  market.to_i
                end
    joins(organizations: :market_organizations).
      merge(Organization.active).
      where(market_organizations: {market_id: market_id}).
      merge(MarketOrganization.visible)
  }

  scope :subscribed_to, ->(subscription) {
    where_opts = case subscription
             when SubscriptionType
               {subscription_types: {id: subscription.id}}
             when Fixnum
               {subscription_types: {id: subscription}}
             else
               {subscription_types: {keyword: subscription.to_s}}
             end
    joins(subscriptions: :subscription_type).
    where(where_opts).
    merge(Subscription.visible)
  }

  def self.arel_column_for_sort(column_name)
    if column_name == "email"
      arel_table[:email]
    else
      arel_table[:name]
    end
  end

  def member_of_organization?(target)
    target && user_organizations.find { |o| o.organization_id == target.id } != nil
  end

  def active_subscriptions
    subscriptions.visible
  end

  def active_subscription_types
    subscription_types.merge(Subscription.visible)
  end

  def subscribe_to(s)
    keyword = case s
              when SubscriptionType
                s.keyword
              else
                s.to_s
              end
    st = SubscriptionType.find_by(keyword: keyword)
    raise "No SubscriptionType found for keyword #{keyword.inspect}" unless st
    if sub = subscriptions.find_by(subscription_type: st)
      sub.undelete
    else
      subscription_types << st
    end
    active_subscription_types
  end

  def unsubscribe_from(s)
    keyword = case s
              when SubscriptionType
                s.keyword
              else
                s.to_s
              end
    st = SubscriptionType.find_by(keyword: keyword)
    raise "No SubscriptionType found for keyword #{keyword.inspect}" unless st
    if sub = subscriptions.find_by(subscription_type: st)
      sub.soft_delete
    end

    active_subscription_types
  end

  def unsubscribe_token(subscription_type:)
    subscription_type_id = subscription_type.id
    subscriptions.each.
      select { |s| s.subscription_type_id == subscription_type_id }.
      first.
      try(:token)
  end

  def affiliations
    @affiliations ||= begin
      collection = []

      collection += managed_markets
      collection += organizations_including_suspended.order(name: :asc).select {|o| o.has_market? }

      collection
    end
  end

  def terms_of_service=(terms_of_service)
    @terms_of_service = terms_of_service
    @accepted_terms_of_service_at = Time.now
  end

  def self.for_search(query)
    search_by_name_and_email(query)
  end

  def self.for_auth_token(token)
    return if token.blank?

    hsh = auth_token_verifier.verify(token)
    User.find_by(id: hsh[:id]) if hsh[:expires] > Time.now.to_i
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    nil
  end

  def self.auth_token_verifier
    Rails.application.message_verifier(:user_auth_token)
  end

  def auth_token(expires_in=1.hour)
    self.class.auth_token_verifier.generate(a: rand(100), id: id, expires: expires_in.from_now.to_i, b: rand(100))
  end

  def admin?
    return @admin if !@admin.nil?
    @admin = user_organizations.includes(:organization).where(organizations: {org_type: Organization::TYPE_ADMIN}).exists?
  end

  def can_manage?(resource)
    self.send("can_manage_#{resource.class.name.underscore}?", resource)
  end

  def can_manage_organization?(org)
    admin? || managed_organizations.include?(org)
  end

  def can_manage_market?(market)
    admin? || managed_markets.all.include?(market)
  end

  def can_manage_user?(user)
    admin? || user.market_manager? || user.organizations_including_suspended.any? {|org| can_manage_organization?(org) }
  end

  def enabled_for_organization?(org)
    user_organizations.where(enabled: true, organization_id: org.id).exists?
  end

  def suspended_from_all_orgs?(market)
    return if market.nil?

    (market.organizations & organizations).empty? && !(market.organizations & suspended_organizations).empty?
  end

  def market_manager?
    return false if admin?
    return @market_manager if !@market_manager.nil?
    @market_manager = user_organizations.includes(:organization).where(organizations: {org_type: Organization::TYPE_MARKET}).exists?
  end

  def seller?
    return false if admin? || market_manager?
    return @seller if !@seller.nil?
    @seller = user_organizations.
                includes(:organization).
                where(organizations: {org_type: Organization::TYPE_SUPPLIER}).
                exists?
  end

  def admin_or_mm?
    market_manager? || admin?
  end

  def buyer_only?
    return false if admin? || market_manager? || seller?
    return @buyer if !@buyer.nil?
    @buyer = user_organizations.
               includes(:organization).
               where(
                 organizations: {org_type: Organization::TYPE_BUYER}
               ).exists?
  end

  def is_seller_with_purchase?
    seller? && Order.where(organization_id: organization_ids).exists?
  end

  def primary_user_role
    @primary_user_role ||= if admin?
      "A"
    elsif market_manager?
      "M"
    elsif seller?
      "S"
    elsif buyer_only?
      "B"
    end
  end

  def managed_organizations(opts={})
    opts.reverse_merge! include_suspended: false

    org_membership_scope = opts[:include_suspended] ? organizations_including_suspended : organizations

    @managed_organizations ||= {include_suspended: {true => nil, false => nil}}

    @managed_organizations[:include_suspended][opts[:include_suspended]] ||= Organization.managed_by_market_ids(ids_for_managed_organizations).
      where(market_organizations: {deleted_at: nil}).
      where.not(market_organizations: {id: nil}).
      union(org_membership_scope).
      joins(:market_organizations).
      distinct
  end

  def managed_organizations_including_cross_sellers(opts={})
    opts.reverse_merge! include_suspended: false

    org_membership_scope = opts[:include_suspended] ? organizations_including_suspended : organizations

    @managed_organizations_including_cross_sellers ||= {include_suspended: {true => nil, false => nil}}

    @managed_organizations_including_cross_sellers[:include_suspended][opts[:include_suspended]] ||= Organization.all_for_market_ids(ids_for_managed_organizations).
      where(market_organizations: {deleted_at: nil}).
      where.not(market_organizations: {id: nil}).
      union(org_membership_scope).
      joins(:market_organizations).
      distinct.
      order(:name)
  end

  def managed_organizations_including_deleted
    @managed_organizations_including_deleted ||= if admin?
      Organization.all
    else
      Organization.managed_by_market_ids(managed_market_ids).
        union(organizations).
        joins(:market_organizations).
        order(:name).
        distinct
    end
  end

  def managed_organization_ids_including_deleted
    @managed_organization_ids_including_deleted ||= managed_organizations_including_deleted.map(&:id)
  end

  def managed_organizations_within_market_including_crossellers(market)
    if admin? || market.length > 0
      market.each do |m|
        result = m.organizations.extending(MarketOrganization::AssociationScopes).excluding_deleted.mo_join_market_id(m)
        if @r
          @r = @r + result
        else
          @r = result
        end
      end
      @r.uniq.sort_by{|e| e[:name]}
    else
      organizations.extending(MarketOrganization::AssociationScopes).joins(:market_organizations).excluding_deleted.mo_join_market_id(market)
    end
  end

  def managed_organizations_within_market(market)
    if admin? || managed_markets.include?(market)
      market.organizations.extending(MarketOrganization::AssociationScopes).excluding_deleted.not_cross_selling.mo_join_market_id(market.id)
    elsif buyer_only?
      organizations.extending(MarketOrganization::AssociationScopes).joins(:market_organizations).excluding_deleted.not_cross_selling.mo_join_market_id(market.id)
    else
      organizations.extending(MarketOrganization::AssociationScopes).joins(:market_organizations).excluding_deleted.not_cross_selling
    end
  end

  def multi_organization_membership?
    @multi_organization_membership ||= managed_organizations.count > 1
  end

  def markets
    @markets ||= if admin?
      Market.all
    else
      markets_for_non_admin_including_cross_selling
    end
  end

  def multi_market_membership?
    markets.count > 1
  end

  def cross_sold_products
    managed_market_ids  = managed_markets.pluck(:id)
    cross_selling_lists = CrossSellingList.active.subscriptions.where(entity_type: "Market", entity_id: managed_market_ids).pluck(:id)
    cross_sold_products = CrossSellingListProduct.where(cross_selling_list_id: cross_selling_lists).pluck(:product_id)
  end

  def managed_products
    organization_ids = managed_organizations.map(&:id)
    cross_sold_prods = cross_sold_products
    Product.visible.seller_can_sell.where("products.organization_id IN (?) OR products.id IN (?)", organization_ids, cross_sold_prods)
  end

  def buyers_for_select
    for_select = []
    markets.each do |m|
      by_market = m.organizations.map {|o| [o.name, o.id] }
      for_select |= (by_market)
    end
    for_select.sort {|a, b| a[0] <=> b[0] }
  end

  def markets_for_select
    for_select = markets.map do |m|
      [m.name, m.id]
    end
    for_select.sort {|a, b| a[0] <=> b[0] }
  end

  def send_import_password_reset_instructions
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)

    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.now.utc + 3.weeks # 4 week expiration for imported users
    save(validate: false)

    if !Rails.env.staging?
      send_devise_notification(:reset_import_password_instructions, raw, {})
    elsif email == "anna+manager@localorb.it" || email == "chris.rittersdorf+buyer@collectiveidea.com"
      send_devise_notification(:reset_import_password_instructions, raw, {})
    end
    raw
  end

  def pretty_email
    if !email.nil?
      "#{name.to_s.inspect} <#{email}>"
    else
      nil
    end
  end

  def default_market
    @default_market ||= if admin?
      Market.find_by(subdomain: 'admin')
    elsif market_manager?
      managed_markets.active.first
    else
      # Prefer active Organizations, but if can't find any active Orgs
      # then pick the most recently created Org for this user
      Market.joins(market_organizations: {organization: :user_organizations}).
        merge(Market.active).
        merge(MarketOrganization.excluding_deleted).
        merge(MarketOrganization.not_cross_selling).
        merge(UserOrganization.enabled).
        where(user_organizations: {user_id: id}).
        order(
          Organization.arel_table[:active].desc,
          Organization.arel_table[:created_at].desc).
        first
    end
  end

  def is_invited?
    invitation_token != nil && !confirmed?
  end

  private

  def standard_market_ids
    organization_member_market_ids = organizations.map(&:all_market_ids).flatten
    managed_market_ids + organization_member_market_ids
  end

  def cross_selling_market_ids
    publishing_list_ids = CrossSellingList.where(creator: true, entity_type: 'Market', entity_id: standard_market_ids).pluck(:id)

    CrossSellingList.where(creator: false, status: 'Published', deleted_at: nil, parent_id: publishing_list_ids).pluck(:entity_id)
  end

  def markets_for_non_admin
    Market.where(id: standard_market_ids)
  end

  def markets_for_non_admin_including_cross_selling
    Market.where(id: (standard_market_ids + cross_selling_market_ids))
  end

  def ids_for_managed_organizations
    @ids ||= begin
      if admin?
        Market.all.pluck(:id)
      elsif market_manager?
        managed_market_ids
      end
    end
  end
end
