class OrderTotals
  include TotalsPresenter

  attr_reader :items

  def initialize(items)
    @items = items
  end
end
