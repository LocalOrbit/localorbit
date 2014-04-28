class CreateOrder
  include Interactor

  def perform
    order = Order.create_from_cart(order_params, cart, buyer)
    if context.include?(:payment)
      order.payments << payment
      order.update(payment_status: payment.status)
    end

    context[:order] = order
    context.fail! if context[:order].errors.any?
  end
end
