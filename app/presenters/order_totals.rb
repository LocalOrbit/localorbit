class OrderTotals
  include TotalsPresenter

  attr_reader :items

  def initialize(items)
    @items = items
  end

  def filtered_gross_total(order)
    filtered_order_items = @items.where(order: order)
    if filtered_order_items.size == order.items.size
      order.gross_total
    else
      filtered_order_items.map(&:gross_total).sum
    end
  end
end
