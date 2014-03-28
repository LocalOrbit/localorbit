class Order < ActiveRecord::Base
  belongs_to :market
  belongs_to :organization
  belongs_to :delivery
  has_many :items, inverse_of: :order, class: OrderItem

  validates :billing_address, presence: true
  validates :billing_city, presence: true
  validates :billing_organization_name, presence: true
  validates :billing_phone, presence: true
  validates :billing_state, presence: true
  validates :billing_zip, presence: true
  validates :delivery_address, presence: true
  validates :delivery_city, presence: true
  validates :delivery_fees, presence: true
  validates :delivery_id, presence: true
  validates :delivery_phone, presence: true
  validates :delivery_state, presence: true
  validates :delivery_status, presence: true
  validates :delivery_zip, presence: true
  validates :market_id, presence: true
  validates :order_number, presence: true
  validates :organization_id, presence: true
  validates :payment_method, presence: true
  validates :payment_status, presence: true
  validates :placed_at, presence: true
  validates :total_cost, presence: true

  def self.orders_for_buyer(user)
    if user.admin?
      all
    elsif user.market_manager?
      select('orders.*').
      joins("LEFT JOIN user_organizations ON user_organizations.organization_id = orders.organization_id
             LEFT JOIN managed_markets ON managed_markets.market_id = orders.market_id").
      where("user_organizations.user_id = :user_id OR managed_markets.user_id = :user_id", user_id: user.id)
    else
      select('orders.*').joins("INNER JOIN user_organizations ON user_organizations.organization_id = orders.organization_id").
        where('user_organizations.user_id = ?', user.id)
    end
  end

  def self.orders_for_seller(user)
    if user.admin?
      all
    elsif user.market_manager?
      select('orders.*').
      joins("INNER JOIN order_items ON order_items.order_id = orders.id
             INNER JOIN products ON products.id = order_items.product_id
             LEFT JOIN user_organizations ON user_organizations.organization_id = products.organization_id
             LEFT JOIN managed_markets ON managed_markets.market_id = orders.market_id").
      where("user_organizations.user_id = :user_id OR managed_markets.user_id = :user_id", user_id: user.id)
    else
      select('orders.*').
      joins("INNER JOIN order_items ON order_items.order_id = orders.id
             INNER JOIN products ON products.id = order_items.product_id
             LEFT JOIN user_organizations ON user_organizations.organization_id = products.organization_id").
      where("user_organizations.user_id = :user_id", user_id: user.id)
    end
  end

  def self.create_from_cart(cart)
    billing = cart.organization.locations.default_billing

    order = Order.new(
      order_number: "LO-14-0-00000",
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
      payment_method: "Purchase Order",
      delivery_fees: cart.delivery_fees,
      total_cost: cart.total,
      placed_at: DateTime.current
    )

    address = cart.delivery.delivery_schedule.buyer_pickup? ?
      cart.delivery.delivery_schedule.buyer_pickup_location : cart.location

    order.delivery_address = address.address
    order.delivery_city    = address.city
    order.delivery_state   = address.state
    order.delivery_zip     = address.zip
    order.delivery_status  =  "Pending"
    order.delivery_phone   = address.phone

    cart.items.each do |item|
      order.items << OrderItem.build_from_cart_item(item, cart.delivery.deliver_on)
    end

    order.save
    order
  end
end
