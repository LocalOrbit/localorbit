class AddItemsToOrder
  include Interactor

  def perform
    ActiveRecord::Base.transaction do
      item_hashes.each do |item_hash|
        product = Product.find(item_hash[:product_id])
        cart = Cart.new(market: order.market, organization: order.organization, delivery: order.delivery)
        cart_item = CartItem.new(cart: cart, product: product, quantity: item_hash[:quantity].to_i)
        order.items << OrderItem.create_with_order_and_item_and_deliver_on_date(order: order, item: cart_item, deliver_on_date: order.delivery.deliver_on)
      end

      unless order.save
        fail!
        raise ActiveRecord::Rollback
      end
    end

    order
  end
end