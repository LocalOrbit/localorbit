class BuyerOrder
  include ActiveModel::Model
  include OrderPresenter
  include DeliveryStatus

  delegate :display_delivery_or_pickup,
    :display_delivery_address,
    :delivery_id,
    :deliver_on,
    :organization_id,
    :invoice_pdf,
    :credit,
    :credit_amount,
    :total_cost,
    :invoice_due_date,
    :delivery_date,
    :gross_total,
    :sellers,
    :signature_data,
    :order_type,
    :sales_order?,
    :purchase_order?,
    :created_at,
    :delivery_status,
    :sold_through,
    :payment_method,
    :delivery_fees,
    to: :@order

  def initialize(order)
    @order = order.decorate
    @items = order.items
  end

  def self.find(buyer, id)
    order = Order.orders_for_buyer(buyer).find(id)
    new(order)
  end
end
