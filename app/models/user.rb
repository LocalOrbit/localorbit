class User < ActiveRecord::Base
  audited allow_mass_assignment: true
  include PgSearch
  include Sortable
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :masqueradable

  has_many :managed_markets_join, class_name: "ManagedMarket"

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

  attr_accessor :terms_of_service

  validates :terms_of_service, acceptance: true, on: :create

  pg_search_scope :search_by_name_and_email,
                  against: {name: "A", email: "B"},
                  using: {tsearch: {prefix: true}}

  scope_accessible :sort, method: :for_sort, ignore_blank: true
  scope_accessible :search, method: :for_search, ignore_blank: true

  scope :buyers, -> { joins(:organizations).merge(Organization.buying) }
  scope :sellers, -> { joins(:organizations).merge(Organization.selling) }
  
  scope :in_market, ->(market) { 
    market_id = case market
                when Market
                  market.id
                else
                  market.to_i
                end
    joins(organizations: :market_organizations).
    where(market_organizations: {market_id: market_id}).
    merge(MarketOrganization.visible)
  }

  # TODO: this needs a spec if we're to bring it in:
  # scope :managing_market, ->(market) {
  #   market_id = case market
  #               when Market
  #                 market.id
  #               else
  #                 market.to_i
  #               end
  #   joins(:managed_markets).
  #   where(managed_markets: {market_id: market_id})
  # }
 
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

  def self.with_primary_market(market)
    User.all.select {|u| u.primary_market == market }
  end

  def self.arel_column_for_sort(column_name)
    if column_name == "email"
      arel_table[:email]
    else
      arel_table[:name]
    end
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
    role == "admin"
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
    admin? || user.organizations_including_suspended.any? {|org| can_manage_organization?(org) }
  end

  def enabled_for_organization?(org)
    user_organizations.find_by(organization: org).try(:enabled?)
  end

  def suspended_from_all_orgs?(market)
    # return if organizations.nil?
    return if market.nil?

    (market.organizations & organizations).empty? && !(market.organizations & suspended_organizations).empty?
  end

  def market_manager?
    managed_markets.any?
  end

  def seller?
    organizations.selling.any?
  end

  def buyer_only?
    !admin? && !market_manager? && !seller?
  end

  def is_seller_with_purchase?
    seller? && Order.where(organization_id: organization_ids).exists?
  end

  def managed_organizations(opts={})
    defaults = {include_suspended: false}
    opts = defaults.merge!(opts)

    org_membership_scope = opts[:include_suspended] ? organizations_including_suspended : organizations

    @managed_organizations ||= {include_suspended: {true => nil, false => nil}}

    @managed_organizations[:include_suspended][opts[:include_suspended]] ||= Organization.managed_by_market_ids(ids_for_managed_organizations).
      where(market_organizations: {deleted_at: nil}).
      where.not(market_organizations: {id: nil}).
      union(org_membership_scope).
      joins(:market_organizations).
      distinct
  end

  def managed_organizations_including_deleted
    if admin?
      Organization.all
    else
      market_ids = managed_markets_join.map(&:market_id)

      Organization.managed_by_market_ids(market_ids).
        union(organizations).
        joins(:market_organizations).
        order(:name).
        distinct
    end
  end

  def managed_organization_ids_including_deleted
    managed_organizations_including_deleted.map(&:id)
  end

  def managed_organizations_within_market(market)
    if admin? || managed_markets.include?(market)
      market.organizations.extending(MarketOrganization::AssociationScopes).excluding_deleted.not_cross_selling.mo_join_market_id(market.id)
    else
      organizations.extending(MarketOrganization::AssociationScopes).joins(:market_organizations).excluding_deleted.not_cross_selling.mo_join_market_id(market.id)
    end
  end

  def multi_organization_membership?
    return @multi_organization_membership if defined?(@multi_organization_membership)
    @multi_organization_membership = managed_organizations.count > 1
  end

  # shortcut for grabbing the "primary" market for things like email layout
  # when we don't know. We can make this more intelligent later.
  # confirmation email needs the organizations bit.
  def primary_market
    admin? ? nil : markets.order(:created_at).first
  end

  def markets
    @markets ||= if admin?
      Market.all
    else
      markets_for_non_admin
    end
  end

  def all_markets
    @all_markets ||= if admin?
      Market.all
    else
      all_markets_for_non_admin
    end
  end

  def multi_market_membership?
    markets.count > 1
  end

  def multi_market_membership_broadly_speaking?
    all_markets.count > 1
  end

  def managed_products
    org_ids = managed_organizations.map(&:id)
    Product.visible.seller_can_sell.where(organization_id: org_ids)
  end

  def buyers_for_select
    for_select = []
    markets.each do |m|
      by_market = m.organizations.map {|o| [o.name, o.id] }
      for_select |= (by_market)
    end
    for_select.sort {|a, b| a[0] <=> b[0] }
  end

  def all_buyers_for_select
    for_select = []
    all_markets.each do |m|
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
  
  def all_markets_for_select
    for_select = all_markets.map do |m|
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
    "#{name.to_s.inspect} <#{email}>"
  end

  def default_market
    if admin?
      admin_market = markets.select do |m| m.subdomain == "admin" end.first
      if admin_market
        admin_market
      else
        markets.first
      end
    else
      markets.first
    end
  end

  private

  def markets_for_non_admin
    managed_market_ids = managed_markets.pluck(:id)

    organization_member_market_ids = organizations.map(&:market_ids).flatten
    Market.where(id: (managed_market_ids + organization_member_market_ids))
  end

  def all_markets_for_non_admin
    managed_market_ids = managed_markets.pluck(:id)

    organization_member_market_ids = organizations.map(&:all_market_ids).flatten
    Market.where(id: (managed_market_ids + organization_member_market_ids))
  end

  def ids_for_managed_organizations
    @ids ||= begin
      if admin?
        Market.all.pluck(:id)
      elsif market_manager?
        managed_markets_join.map(&:market_id)
      end
    end
  end
end
