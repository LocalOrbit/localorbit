class OrderItem < ActiveRecord::Base
  attr_accessor :deliver_on_date

  belongs_to :order, inverse_of: :items
  belongs_to :product
  has_many :lots, inverse_of: :order_item, class: OrderItemLot, autosave: true

  validates :product, presence: true
  validates :name, presence: true
  validates :order, presence: true
  validates :seller_name, presence: true
  validates :quantity, presence: true
  validates :unit, presence: true
  validates :unit_price, presence: true
  validates :delivery_status, presence: true

  validate  :product_availability, on: :create

  before_create :consume_inventory

  def self.for_delivery(delivery)
    joins(order: :delivery).where(orders: { delivery_id: delivery.id })
  end

  def self.create_with_order_and_item_and_deliver_on_date(opts={})
    item = opts[:item]
    order = opts[:order]

    create(
      deliver_on_date: opts[:deliver_on_date],
      order: order,
      product: item.product,
      name: item.product.name,
      quantity: item.quantity,
      unit: item.unit,
      unit_price: item.unit_price.sale_price,
      seller_name: item.product.organization.name,
      delivery_status: "pending"
    )
  end

  def seller_net_total
    unit_price * quantity - market_seller_fee - local_orbit_seller_fee - payment_seller_fee
  end

  def gross_total
    unit_price * quantity
  end

  def product_availability
    return unless product.present?

    quantity_available = product.lots_by_expiration.available.sum(:quantity)

    if quantity_available < quantity
      errors[:inventory] = "there are only #{quantity_available} #{product.name.pluralize(quantity_available)} available."
    end
  end

  def seller
    product.organization
  end

  private
  def consume_inventory
    quantity_remaining = quantity

    product.lots_by_expiration.available(deliver_on_date).each do |lot|
      break unless quantity_remaining

      num_to_consume = [lot.quantity, quantity_remaining].min
      lot.decrement!(:quantity, num_to_consume)

      lots.build(lot: lot, quantity: num_to_consume)
      quantity_remaining -= num_to_consume
    end
  end
end
