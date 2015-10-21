class AddItemsToOrder
  include Interactor

  def perform
    ActiveRecord::Base.transaction do
      item_hashes.each do |item_hash|
        delivery = order.delivery
        product = Product.find(item_hash[:product_id])
        cart = Cart.new(market: order.market, organization: order.organization, delivery: delivery)
        cart_item = CartItem.new(cart: cart, product: product, quantity: item_hash[:quantity].to_i)
        order.add_cart_item(cart_item, delivery.deliver_on)
        delivery_notes = DeliveryNote.where(cart_id:cart.id) # TODO check.. loc for this
        order.add_notes_reference(delivery_notes) # TODO: in view, supplier should see all notes for that order that are for them and NOT others
      end

      unless order.save
        fail!
        raise ActiveRecord::Rollback
      end
    end

    order
  end
end
