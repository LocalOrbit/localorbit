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

  def self.build_from_cart_item(item, deliver_on_date)
    order_item = OrderItem.new(
      product: item.product,
      name: item.product.name,
      quantity: item.quantity,
      unit: item.unit,
      unit_price: item.unit_price.sale_price,
      seller_name: item.product.organization.name
    )

    quantity_remaining = item.quantity
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

    order_item
  end

  def seller_net_total
    unit_price * quantity - market_fees - localorbit_seller_fees - payment_seller_fees
  end

  def gross_total
    unit_price * quantity
  end
end
