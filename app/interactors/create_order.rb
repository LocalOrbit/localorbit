class CreateOrder
  include Interactor

  def perform
    context[:order] = Order.create_from_cart(order_params, cart, buyer)
    context.fail! if context[:order].errors.any?
  end

  def rollback
    if context[:order]
      context[:order].destroy
    end
  end
end
