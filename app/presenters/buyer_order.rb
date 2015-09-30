class BuyerOrder
  include ActiveModel::Model
  include OrderPresenter
  include DeliveryStatus

  delegate :display_delivery_or_pickup, :display_delivery_address, :delivery_id, :organization_id, :invoice_pdf, :credit, :sellers, to: :@order

  def initialize(order)
    @order = order.decorate
    @items = order.items
  end

  def self.find(buyer, id)
    order = Order.orders_for_buyer(buyer).find(id)
    new(order)
  end

  def total_cost
    @order.total_cost
  end

  def invoice_due_date
    @order.invoice_due_date
  end

  def delivery_date
    @order.delivery_date
  end

  def gross_total
    @order.gross_total
  end

  def credit_amount
    @order.credit_amount
  end
end
