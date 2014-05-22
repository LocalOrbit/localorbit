class CreateOrder
  include Interactor

  def perform
    order = Order.create_from_cart(order_params, cart, buyer)

    context[:order] = order
    context.fail! if context[:order].errors.any?
  end
end
