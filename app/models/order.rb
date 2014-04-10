class Order < ActiveRecord::Base
  include DeliveryStatus

  belongs_to :market
  belongs_to :organization
  belongs_to :delivery
  belongs_to :placed_by, class: User

  has_many :items, inverse_of: :order, class: OrderItem, autosave: true

  validates :billing_address, presence: true
  validates :billing_city, presence: true
  validates :billing_organization_name, presence: true
  validates :billing_state, presence: true
  validates :billing_zip, presence: true
  validates :delivery_address, presence: true
  validates :delivery_city, presence: true
  validates :delivery_fees, presence: true
  validates :delivery_id, presence: true
  validates :delivery_state, presence: true
  validates :delivery_zip, presence: true
  validates :market_id, presence: true
  validates :order_number, presence: true, uniqueness: true
  validates :organization_id, presence: true
  validates :payment_method, presence: true
  validates :payment_status, presence: true
  validates :placed_at, presence: true
  validates :total_cost, presence: true

  scope :recent, -> { order("created_at DESC").limit(15) }
  scope :upcoming_delivery, -> { joins(:delivery).where("deliveries.deliver_on > ?", Time.current) }

  def self.orders_for_buyer(user)
    if user.admin?
      all
    elsif user.market_manager?
      select("orders.*").
      joins("LEFT JOIN user_organizations ON user_organizations.organization_id = orders.organization_id
             LEFT JOIN managed_markets ON managed_markets.market_id = orders.market_id").
      where("user_organizations.user_id = :user_id OR managed_markets.user_id = :user_id", user_id: user.id)
    else
      select("orders.*").joins("INNER JOIN user_organizations ON user_organizations.organization_id = orders.organization_id").
        where("user_organizations.user_id = ?", user.id)
    end
  end

  def self.orders_for_seller(user)
    if user.admin?
      all
    elsif user.market_manager?
      select("DISTINCT orders.*").
      joins("INNER JOIN order_items ON order_items.order_id = orders.id
             INNER JOIN products ON products.id = order_items.product_id
             LEFT JOIN user_organizations ON user_organizations.organization_id = products.organization_id
             LEFT JOIN managed_markets ON managed_markets.market_id = orders.market_id").
      where("user_organizations.user_id = :user_id OR managed_markets.user_id = :user_id", user_id: user.id)
    else
      select("DISTINCT orders.*").
      joins("INNER JOIN order_items ON order_items.order_id = orders.id
             INNER JOIN products ON products.id = order_items.product_id
             LEFT JOIN user_organizations ON user_organizations.organization_id = products.organization_id").
      where("user_organizations.user_id = :user_id", user_id: user.id)
    end
  end

  def self.undelivered_orders_for_seller(user)
    scope = orders_for_seller(user)
    scope = scope.joins(:order_items) if user.admin?
    scope.where(order_items: {delivery_status: "pending"})
  end

  def self.create_from_cart(params, cart, buyer)
    billing = cart.organization.locations.default_billing
    order_number = OrderNumber.new(cart.market)

    order = Order.new(
      placed_by: buyer,
      order_number: order_number.id,
      organization: cart.organization,
      market: cart.market,
      delivery: cart.delivery,
      billing_organization_name: cart.organization.name,
      billing_address: billing.address,
      billing_city: billing.city,
      billing_state: billing.state,
      billing_zip: billing.zip,
      billing_phone: billing.phone,
      payment_status: "Not Paid",
      payment_method: params[:payment_method],
      delivery_fees: cart.delivery_fees,
      total_cost: cart.total,
      placed_at: DateTime.current
    )

    order.payment_note = params[:payment_note] if params[:payment_note]

    address = cart.delivery.delivery_schedule.buyer_pickup? ?
      cart.delivery.delivery_schedule.buyer_pickup_location : cart.location

    order.delivery_address = address.address
    order.delivery_city    = address.city
    order.delivery_state   = address.state
    order.delivery_zip     = address.zip
    order.delivery_phone   = address.phone

    ActiveRecord::Base.transaction do
      cart.items.each do |item|
        order.items << OrderItem.create_with_order_and_item_and_deliver_on_date(order: order, item: item, deliver_on_date: cart.delivery.deliver_on)
      end

      raise ActiveRecord::Rollback unless order.save
    end

    order
  end

  def sellers
    items.map {|item| item.seller }.uniq
  end

  def self.joining_products
    joins(items: :product).includes(:items).group("orders.id").order("organization_id DESC")
  end

  def self.order_items_by_product
    joining_products.map {|order| order.items }.flatten.group_by(&:product)
  end

  def self.order_items_by_product_for_organization(organization)
    joining_products.where(products: {organization_id: organization.id}).
      map(&:items).flatten.group_by(&:product)
  end
end
