class OrdersBySellerPresenter
  attr_accessor :sellers
  attr_accessor :totals

  def initialize(items, in_seller = nil)
    @totals = {}
    @sellers = {}

    items.undelivered.each do |item|
      seller = item.product.organization

      if in_seller && seller.id != in_seller.id
        next
      end

      @sellers[seller] ||= {}
      @sellers[seller][item.order] ||= []
      @sellers[seller][item.order] << item
      @totals[seller] ||= 0
      @totals[seller] += item.seller_net_total
    end
  end
end
