class OrdersBySellerPresenter
  attr_accessor :sellers
  attr_accessor :totals

  def initialize(items)
    @totals = {}
    @sellers = {}

    items.undelivered.each do |item|
      seller = item.product.organization
      @sellers[seller] ||= {}
      @sellers[seller][item.order] ||= []
      @sellers[seller][item.order] << item
      @totals[seller] ||= 0
      @totals[seller] += item.seller_net_total
    end
  end
end
