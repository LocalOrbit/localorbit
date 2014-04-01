class CreateOrder
  include Interactor

  def perform
    context[:order] = Order.create_from_cart(order_params, cart)
    context.fail! unless context[:order].persisted?
  end
end
