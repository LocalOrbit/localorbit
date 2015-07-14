class OrderTotals
  include TotalsPresenter

  attr_reader :items, :gross_totals

  def initialize(items)
    @items = items
    @gross_totals = calculate_gross_totals(items)
  end

  def calculate_gross_totals(items)
    gross_totals = []
    items.each do |item|
      gross_totals[item.order_id] ||= 0
      gross_totals[item.order_id] += item.gross_total
    end
    gross_totals
  end
end
