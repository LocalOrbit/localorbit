class OrderItem < ActiveRecord::Base
  DELIVERY_STATUSES = %w(pending canceled delivered contested)

  attr_accessor :deliver_on_date

  belongs_to :order, inverse_of: :items
  belongs_to :product
  has_many :lots, inverse_of: :order_item, class: OrderItemLot, autosave: true, dependent: :destroy

  validates :product, presence: true
  validates :name, presence: true
  validates :seller_name, presence: true
  validates :quantity, presence: true
  validates :unit, presence: true
  validates :unit_price, presence: true
  validates :delivery_status, presence: true, inclusion: {in: DELIVERY_STATUSES}

  validate :product_availability, on: :create

  before_create :consume_inventory
  before_save :update_delivered_at
  before_save :update_quantity_delivered

  def self.for_delivery(delivery)
    joins(order: :delivery).where(orders: {delivery_id: delivery.id})
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

  def self.for_delivery_and_user(delivery, user)
    ids = user.managed_organizations.map(&:id)
    OrderItem.for_delivery(delivery).joins(:product).where(products: {organization_id: ids})
  end

  def self.for_user(user)
    joins(:product).where(products: {organization_id: user.managed_organizations.pluck(:id).uniq})
  end

  def buyer_payment_status
    order.payment_status
  end

  def seller_net_total
    gross_total - market_seller_fee - local_orbit_seller_fee - payment_seller_fee
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

  def seller_payment_status
    @seller_payment_status ||= order.paid_seller_ids.include?(product.organization_id) ? 'Paid' : 'Unpaid'
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

  def update_delivered_at
    if changes[:delivery_status] && changes[:delivery_status][1] == "delivered"
      self.delivered_at ||= Time.current
    end
  end

  def update_quantity_delivered
    if delivery_status_changed? && delivery_status == "delivered"
      self.quantity_delivered ||= quantity
    end
  end
end
