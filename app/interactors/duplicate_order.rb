class DuplicateOrder
  include Interactor

  def perform
    # Retrieve orig_order items
    if !order.nil?
      user = context[:user]
      order = context[:order]
      market = order.market
      delv = order.delivery
      next_delv = delv.delivery_schedule.next_delivery
      order_items = order.items

      # Add items to cart object
      items = []
      cart = Cart.create(user: user, market: market, organization: order.organization, delivery: next_delv)
      order_items.each do |o_item|
        product = Product.find(o_item.product_id)
         item = CartItem.create(cart: cart, product: product, quantity: o_item.quantity.to_i)
         item.save!(validate: false)
      end
      cart.save!
      context[:cart_id] = cart.id
      context[:current_organization_id] = order.organization.id
      context[:current_delivery_id] = next_delv.id
      context[:current_delivery_day] = next_delv.deliver_on
    end
  end
end
