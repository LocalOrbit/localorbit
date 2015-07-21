class CreateOrder
  include Interactor

  def perform
    context[:order] = create_order_from_cart(order_params, cart, buyer)
    context.fail! if context[:order].errors.any?
  end

  def rollback
    if context[:order]
      OrderNumber.relinquish(context[:order])
      context[:order].destroy
    end
  end

  def rollback_order(order)
    OrderNumber.relinquish(order.order_number)
  end

  protected

  def create_order_from_cart(params, cart, buyer)

    billing = cart.organization.locations.default_billing

    order = Order.new(
      payment_provider: payment_provider,
      placed_by: buyer,
      order_number: OrderNumber.new(cart.market).id,
      organization: cart.organization,
      market: cart.market,
      delivery: cart.delivery,
      discount: discount,
      billing_organization_name: cart.organization.name,
      billing_address: billing.address,
      billing_city: billing.city,
      billing_state: billing.state,
      billing_zip: billing.zip,
      billing_phone: billing.phone,
      payment_status: "unpaid",
      payment_method: params[:payment_method],
      payment_note: params[:payment_note],
      delivery_fees: cart.delivery_fees,
      total_cost: cart.total,
      placed_at: DateTime.current
    )

    order.apply_delivery_address(cart.delivery_location)

    success = false
    ActiveRecord::Base.transaction do
      begin
        order.add_cart_items(cart.items, cart.delivery.deliver_on)
        success = order.save 
      rescue
        # empty
      end
      unless success
        raise ActiveRecord::Rollback
      end
    end
    unless success
      rollback_order(order)
    end

    order
  end

  def discount
    cart.discount if cart.has_valid_discount?
  end
end
