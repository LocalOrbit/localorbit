class OrderItem < ActiveRecord::Base
  DELIVERY_STATUSES = %w(pending canceled delivered)

  before_create :consume_inventory
  before_save :update_quantity_ordered
  before_save :update_quantity_delivered
  before_save :update_delivery_status
  before_save :update_delivered_at
  before_save :update_consumed_inventory
  before_destroy :remove_consignment_transaction

  audited allow_mass_assignment: true, associated_with: :order

  attr_accessor :deliver_on_date
  attr_accessor :_destroy
  attr_accessor :preferred_storage_location_id

  belongs_to :order, inverse_of: :items
  belongs_to :product
  has_many :lots, inverse_of: :order_item, class_name: OrderItemLot, autosave: true, dependent: :destroy

  validates :product, presence: true
  validates :name, presence: true
  validates :seller_name, presence: true
  validates :quantity, presence: true, numericality: {greater_than_or_equal_to: 0, less_than: 99999}
  validates :quantity_delivered, numericality: {greater_than_or_equal_to: 0, less_than: 99999, allow_nil: true}
  validates :unit, presence: true
  validates :unit_price, presence: true
  validates :delivery_status, presence: true, inclusion: {in: DELIVERY_STATUSES}

  validate :product_availability, on: :create
  validate :consignment_product_availability, on: [:create, :update]

  scope :delivered,       -> { where(delivery_status: "delivered") }
  scope :undelivered,     -> { where(delivery_status: "pending") }
  scope :sales_orders,    -> { where(orders: {order_type: 'sales'}) }
  scope :purchase_orders, -> { where(orders: {order_type: 'purchase'}) }

  has_one :seller, through: :product, class_name: Organization

  ransacker :order_id do
    Arel.sql("to_char(order_items.order_id, '9999999')")
  end

  def self.for_delivery(delivery)
    joins(order: :delivery).where(orders: {delivery_id: delivery.id})
  end

  def self.for_delivery_date(delivery_date, current_user, market_id)
    if current_user.buyer_only? || current_user.market_manager?
      joins(order: :delivery).where("DATE(deliveries.buyer_deliver_on) = '#{delivery_date}' AND orders.market_id = #{market_id}")
    else
      joins(order: :delivery).where("DATE(deliveries.deliver_on) = '#{delivery_date}' AND orders.market_id = #{market_id}")
    end
  end

  def self.create_with_order_and_item_and_deliver_on_date(order, item, deliver_on_date, category_fee_pct)
    new(
      deliver_on_date: deliver_on_date,
      order: order,
      product: item.product,
      name: item.product.name,
      quantity: item.quantity,
      unit: item.unit,
      unit_price: !item.sale_price.nil? && item.sale_price > 0 ? item.sale_price : item.unit_price.nil? ? 0 : item.unit_price.sale_price,
      net_price: !item.net_price.nil? && item.net_price > 0 ? item.net_price : 0,
      product_fee_pct: !item.sale_price.nil? && item.sale_price > 0 ? 0 : item.unit_price.nil? ? 0 : item.unit_price.product_fee_pct,
      category_fee_pct: category_fee_pct.nil? ? 0 : category_fee_pct,
      seller_name: item.product.organization.name,
      delivery_status: "pending"
    )
  end

  def self.for_delivery_and_user(delivery, user)
    ids = user.managed_organization_ids_including_deleted
    OrderItem.for_delivery(delivery).joins(:product).where(products: {organization_id: ids})
  end

  def self.for_delivery_date_and_user(delivery_date, user, market_id)
    ids = user.managed_organization_ids_including_deleted
    OrderItem.for_delivery_date(delivery_date, user, market_id).joins(:product).where(products: {organization_id: ids})
  end

  def self.for_user_purchases(user)
    joins(:order).where(orders: {organization_id: user.managed_organization_ids_including_deleted})
  end

  def self.for_user(user)
    if user.buyer_only?
      for_user_purchases(user)
    else
      joins(:product).where(products: {organization_id: user.managed_organization_ids_including_deleted})
    end
  end

  def buyer_payment_status
    payment_status
  end

  def seller_net_total
    gross_total - market_seller_fee - local_orbit_seller_fee - payment_seller_fee - discount_seller
  end

  def gross_total
    if quantity_delivered.present?
      unit_price * quantity_delivered
    else
      unit_price * quantity
    end
  end

  def discount
    discount_market + discount_seller
  end

  def discounted_total
    gross_total - discount
  end

  def product_availability
    return unless product.present? && !order.nil? && order.market.is_buysell_market?

    if !order.nil?
      market_id = order.market.id
      organization_id = order.organization.id
    end
    qty = product.lots_by_expiration.available_specific(Time.current.end_of_minute, market_id, organization_id).sum(:quantity)
    #if qty == 0
    qty += product.lots_by_expiration.available_general(Time.current.end_of_minute).sum(:quantity)
    #end
    if qty < quantity
      errors[:inventory] = "there are only #{qty} #{product.name.pluralize(qty)} available."
    end
  end

  def consignment_product_availability
    return unless product.present? && !order.nil? && order.market.is_consignment_market? && order.sales_order?

    if !order.nil?
      market_id = order.market.id
      organization_id = order.organization.id
    end
    if !product.lots.empty?
      qty = product.lots_by_expiration.available_specific(Time.current.end_of_minute, market_id, organization_id).sum(:quantity)
      qty += product.lots_by_expiration.available_general(Time.current.end_of_minute).sum(:quantity)
    else
      qty = ConsignmentTransaction.where(transaction_type: 'PO', product_id: product_id, lot_id: nil).sum(:quantity)
    end
    if qty < quantity
      errors[:inventory] = "there are only #{qty} #{product.name.pluralize(qty)} available."
    end
  end

  def seller
    product.organization
  end

  def seller_payment_status
    @seller_payment_status ||= order.paid_seller_ids.include?(product.organization_id) ? "Paid" : "Unpaid"
  end

  def delivered?
    delivery_status == "delivered"
  end

  def remove_consignment_transaction
    ct = ConsignmentTransaction.where(order_id: self.order.id, order_item_id: self.id).first
    if !ct.nil?
      ct.soft_delete
    end
  end

  private

  def consume_inventory
    if !order.nil? && order.sales_order?
      if order
        market_id = order.market.id
        organization_id = order.organization.id
      end
      consume_inventory_amount(quantity, market_id, organization_id)
    end
  end

  def update_delivered_at
    if delivery_status_changed? && delivery_status == "delivered"
      self.delivered_at ||= Time.current
    end
    if delivery_status_changed? && delivery_status == "pending"
      self.delivered_at = nil
    end
  end

  def update_unit_price
    if order && order.market && order.organization
      new_price = Orders::UnitPriceLogic.unit_price(product, order.market, order.organization, order.market.add_item_pricing || persisted? ? order.created_at : Time.current, quantity)
      if new_price != nil && self.net_price == 0
        self.unit_price = new_price.sale_price
      end
    end
  end

  def update_quantity_ordered
    if quantity_changed?
      update_unit_price
      if quantity.present? && delivery_status == "pending" && quantity == 0
        self.delivery_status = "canceled"
        self.payment_status = "refunded" if refundable?
      end
    end
  end

  def update_quantity_delivered
    if should_update_delivery_status?
      self.delivery_status = quantity_delivered > 0 ? "delivered" : "canceled"
      self.payment_status = "refunded" if quantity_delivered == 0 && refundable?
    end
  end

  def should_update_delivery_status?
    quantity_delivered_changed? && quantity_delivered.present? && delivery_status_was == "pending" && delivery_status != "contested"
  end

  def update_delivery_status
    if persisted? && delivery_status_changed?
      if delivery_status == "delivered"
        self.quantity_delivered ||= quantity
      elsif delivery_status == "canceled"
        self.quantity_delivered = 0
        self.payment_status = "refunded" if refundable?
      end
    end
  end

  def consume_inventory_amount(initial_amount, market_id, organization_id)
    specific = false
    amount = initial_amount
    product.lots_by_expiration.available_specific(deliver_on_date, market_id, organization_id).each do |lot|
      break unless amount > 0

      num_to_consume = [lot.quantity, amount].min
      lot.decrement!(:quantity, num_to_consume)

      lots.build(lot: lot, quantity: num_to_consume)
      amount -= num_to_consume
      specific = true
    end

    if amount > 0
      product.lots_by_expiration.available_general(deliver_on_date).each do |lot|
        break unless amount > 0

        num_to_consume = [lot.quantity, amount].min
        lot.decrement!(:quantity, num_to_consume)

        lots.build(lot: lot, quantity: num_to_consume)
        amount -= num_to_consume
      end
    end

    amount = initial_amount
    lots.order(created_at: :desc).each do |lot|
      break unless amount

      num_to_consume = [lot.quantity, amount].min
      lot.increment!(:quantity, num_to_consume)

      amount -= num_to_consume
    end

  end

  def return_inventory_amount(amount)
    lots.order(created_at: :desc).each do |lot|
      break unless amount

      num_to_return = [lot.quantity, amount].min
      lot.lot.increment!(:quantity, num_to_return)
      lot.decrement!(:quantity, num_to_return)

      amount -= num_to_return
    end
  end

  def update_consumed_inventory
    if !order.nil? && order.sales_order?
      if persisted? && quantity_changed?
        quantity_remaining = changes[:quantity][1] - (changes[:quantity][0] || 0)

        if quantity_remaining > 0
          consume_inventory_amount(quantity_remaining, order.market.id, order.organization.id)
        else
          return_inventory_amount(quantity_remaining.abs)
        end
      end
    end
  end

  def refundable?
    ["pending", "paid"].include?(payment_status)
  end

  def share_of_credit
    seller_id = self.product.organization_id
    if order.credit && order.credit.paying_org == nil
      if order.credit.amount_type == "fixed"
        (order.credit_amount / (order.sellers.count || 1)).round 2
      else
        (gross_total / order.gross_total * order.credit_amount).round 2
      end
    elsif order.credit && seller && order.credit.paying_org.id == seller_id
      # When a user belongs to more than one organization that are on the order,
      # the display will be confusing because they won't know which organization
      # is paying the credit.
      order.credit_amount
    else
      0
    end
  end
end
