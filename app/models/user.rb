class User < ActiveRecord::Base
  include PgSearch
  include Sortable
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  has_many :managed_markets_join, class_name: "ManagedMarket"
  has_many :managed_markets, through: :managed_markets_join, source: :market do
    def can_manage_organization?(org)
      joins(:organizations).where(organizations: {id: org.id}).exists?
    end
  end

  has_many :user_organizations
  has_many :organizations, through: :user_organizations
  has_many :carts

  pg_search_scope :search_by_name_and_email,
                    against: {name: 'A', email: 'B'},
                    using: { tsearch: { prefix: true } }

  scope_accessible :sort, method: :for_sort, ignore_blank: true
  scope_accessible :search, method: :for_search, ignore_blank: true

  def self.with_primary_market(market)
    User.all.select{|u| u.primary_market == market }
  end

  def self.for_sort(order)
    column, direction = column_and_direction(order)
    case column
    when "name"
      order_by_name(direction)
    when "email"
      order_by_email(direction)
    end
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

  def auth_token(expires_in = 1.hour)
    self.class.auth_token_verifier.generate(a: rand(100), id: id, expires: expires_in.from_now.to_i, b: rand(100))
  end

  def admin?
    role == "admin"
  end

  def can_manage_organization?(org)
    admin? || managed_markets.can_manage_organization?(org)
  end

  def can_manage_market?(market)
    admin? || managed_markets.all.include?(market)
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

  def managed_organizations
    if admin?
      Organization.all
    elsif market_manager?
      Organization.
        select("DISTINCT organizations.*").
        joins("LEFT JOIN user_organizations ON user_organizations.organization_id = organizations.id
               LEFT JOIN market_organizations ON market_organizations.organization_id = organizations.id AND market_organizations.deleted_at IS NULL").
        where(["user_organizations.user_id = ? OR market_organizations.market_id IN (?)", id, managed_markets_join.map(&:market_id)])
    else
      organizations
    end
  end

  def managed_organizations_within_market(market)
    if admin? || managed_markets.include?(market)
      market.organizations
    else
      organizations.select("organizations.*").joins(:market_organizations).where("market_organizations.market_id" => market.id)
    end
  end

  def multi_organization_membership?
    managed_organizations.count > 1
  end

  # shortcut for grabbing the "primary" market for things like email layout
  # when we don't know. We can make this more intelligent later.
  # confirmation email needs the organizations bit.
  def primary_market
    return nil if admin?
    markets.first || (organizations.first && organizations.first.markets.first)
  end

  def markets
    if admin?
      Market.all
    elsif market_manager?
      Market.
        select("DISTINCT markets.*").
        joins("LEFT JOIN market_organizations ON market_organizations.market_id = markets.id
               LEFT JOIN user_organizations ON user_organizations.organization_id = market_organizations.organization_id
               LEFT JOIN managed_markets ON managed_markets.market_id = markets.id").
        where(["user_organizations.user_id = ? OR managed_markets.user_id = ?", id, id])
    else
      Market.
        select("DISTINCT markets.*").
        joins("INNER JOIN market_organizations ON market_organizations.market_id = markets.id AND market_organizations.cross_sell = 'f'
               INNER JOIN user_organizations ON user_organizations.organization_id = market_organizations.organization_id").
        where("user_organizations.user_id" => id)
    end
  end

  def multi_market_membership?
    markets.count > 1
  end

  def managed_products
    if admin?
      Product.visible.seller_can_sell
    else
      org_ids = managed_organizations.pluck(:id).uniq
      Product.visible.seller_can_sell.where(organization_id: org_ids)
    end
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
    self.reset_password_sent_at = Time.now.utc + 3.weeks #4 week expiration for imported users
    self.save(validate: false)

    if !Rails.env.staging?
      send_devise_notification(:reset_import_password_instructions, raw, {})
    elsif (self.email == "anna+manager@localorb.it" || self.email == "chris.rittersdorf+buyer@collectiveidea.com")
      send_devise_notification(:reset_import_password_instructions, raw, {})
    end
    raw
  end

  private

  def self.order_by_name(direction)
    direction == "asc" ? order("name asc") : order("name desc")
  end

  def self.order_by_email(direction)
    direction == "asc" ? order("email asc") : order("email desc")
  end
end
