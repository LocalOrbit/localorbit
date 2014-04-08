class CreateOrder
  include Interactor

  def perform
    context[:order] = Order.create_from_cart(order_params, cart, buyer)
    context.fail! if context[:order].errors.any?
  end
end
