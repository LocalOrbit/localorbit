class OrderItem < ActiveRecord::Base
  belongs_to :order, inverse_of: :items, autosave: true
  belongs_to :product
  has_many :lots, inverse_of: :order_item, class: OrderItemLot

  validates :name, presence: true
  validates :order, presence: true
  validates :seller_name, presence: true
  validates :quantity, presence: true
  validates :unit, presence: true
  validates :unit_price, presence: true

  class InsufficientInventoryError < RuntimeError
    attr_accessor :product, :remaining, :required
    def initialize(product, remaining, required)
      @product = product
      @remaining = remaining
      @required = required
    end
  end

  def self.create_and_consume_inventory(opts={})
    item = opts[:item]
    deliver_on_date = opts[:deliver_on_date]
    order = opts[:order]

    order_item = new(
      order: order,
      product: item.product,
      name: item.product.name,
      quantity: item.quantity,
      unit: item.unit,
      unit_price: item.unit_price.sale_price,
      seller_name: item.product.organization.name
    )

    if order_item.valid?
      total_available = item.product.lots_by_expiration.available(deliver_on_date).map(&:quantity).sum
      quantity_remaining = item.quantity
      raise InsufficientInventoryError.new(item.product, total_available, item.quantity) if quantity_remaining > total_available

      item.product.lots_by_expiration.available(deliver_on_date).each do |lot|
        break unless quantity_remaining
        if lot.quantity >= quantity_remaining
          order_item.lots << OrderItemLot.new(
            lot: lot,
            quantity: quantity_remaining
          )
          lot.update(quantity: lot.quantity - quantity_remaining)
          break
        else
          order_item.lots << OrderItemLot.new(
            lot: lot,
            quantity: lot.quantity
          )

          quantity_remaining -= lot.quantity
          lot.update(quantity: 0)
        end
      end


      order.items << order_item
    end

    order_item
  end

  def seller_net_total
    unit_price * quantity - market_seller_fee - local_orbit_seller_fee - payment_seller_fee
  end

  def gross_total
    unit_price * quantity
  end
end
