class AddItemsToOrder
  include Interactor

  def perform
    ActiveRecord::Base.transaction do
      item_hashes.each do |item_hash|
        delivery = order.delivery
        product = Product.find(item_hash[:product_id])
        cart = Cart.new(market: order.market, organization: order.organization, delivery: delivery)
        cart_item = CartItem.new(cart: cart, product: product, quantity: item_hash[:quantity].to_i, sale_price: order.market.is_consignment_market? && order.sales_order? ? item_hash[:sale_price].to_f : nil, net_price: order.market.is_consignment_market? && order.sales_order? ? item_hash[:net_price].to_f : nil)
        order.add_cart_item(cart_item, delivery.deliver_on)
      end

      unless order.save
        fail!
        raise ActiveRecord::Rollback
      end
    end

    order
  end
end
