class OrderItem < ActiveRecord::Base
  DELIVERY_STATUSES = %w(pending canceled delivered contested)

  attr_accessor :deliver_on_date
  attr_accessor :_destroy

  belongs_to :order, inverse_of: :items
  belongs_to :product
  has_many :lots, inverse_of: :order_item, class: OrderItemLot, autosave: true, dependent: :destroy

  validates :product, presence: true
  validates :name, presence: true
  validates :seller_name, presence: true
  validates :quantity, presence: true, numericality: {greater_than_or_equal_to: 0, less_than: 2_147_483_647 }
  validates :quantity_delivered, numericality: {greater_than_or_equal_to: 0, less_than: 2_147_483_647, allow_nil: true}
  validates :unit, presence: true
  validates :unit_price, presence: true
  validates :delivery_status, presence: true, inclusion: {in: DELIVERY_STATUSES}

  validate :product_availability, on: :create

  before_create :consume_inventory
  before_save :update_quantity_delivered
  before_save :update_delivery_status
  before_save :update_delivered_at
  before_save :update_consumed_inventory

  ransacker :created_at_date do |parent|
    Arel.sql("DATE(created_at)")
  end

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
    ids = user.managed_organization_ids_including_deleted
    OrderItem.for_delivery(delivery).joins(:product).where(products: {organization_id: ids})
  end

  def self.for_user(user)
    if user.buyer_only?
      joins(:order).where(orders: { organization_id: user.managed_organization_ids_including_deleted })
    else
      joins(:product).where(products: { organization_id: user.managed_organization_ids_including_deleted })
    end
  end

  def buyer_payment_status
    order.payment_status
  end

  def seller_net_total
    gross_total - market_seller_fee - local_orbit_seller_fee - payment_seller_fee
  end

  def gross_total
    if quantity_delivered.present?
      unit_price * quantity_delivered
    else
      unit_price * quantity
    end
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

  def delivered?
    delivery_status == "delivered"
  end

  private

  def consume_inventory
    consume_inventory_amount(quantity)
  end

  def update_delivered_at
    if changes[:delivery_status] && changes[:delivery_status][1] == "delivered"
      self.delivered_at ||= Time.current
    end
  end

  def update_quantity_delivered
    if quantity_delivered_changed? && quantity_delivered.present? && delivery_status == "pending"
      self.delivery_status = quantity_delivered > 0 ? "delivered" : "canceled"
    end
  end

  def update_delivery_status
    if persisted? && delivery_status_changed?
      if delivery_status == "delivered"
        self.quantity_delivered ||= quantity
      elsif delivery_status == "canceled"
        self.quantity_delivered = 0
      end
    end
  end


  def consume_inventory_amount(amount)
    product.lots_by_expiration.available(deliver_on_date).each do |lot|
      break unless amount

      num_to_consume = [lot.quantity, amount].min
      lot.decrement!(:quantity, num_to_consume)

      lots.build(lot: lot, quantity: num_to_consume)
      amount -= num_to_consume
    end
  end

  def return_inventory_amount(amount)
    lots.order(created_at: :desc).each do |lot|
      break unless amount

      num_to_return = [lot.quantity, amount].min
      lot.lot.increment!(:quantity, num_to_return)

      amount -= num_to_return
    end
  end

  def update_consumed_inventory
    if persisted? && quantity_changed?
      quantity_remaining = changes[:quantity][1] - (changes[:quantity][0] || 0)

      if quantity_remaining > 0
        consume_inventory_amount(quantity_remaining)
      else
        return_inventory_amount(quantity_remaining.abs)
      end
    end
  end
end
