class CreateOrder
  include Interactor

  def perform
    context[:order] = create_order_from_cart(order_params, cart, user)
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

  def create_order_from_cart(params, cart, user)

    billing = cart.organization.locations.default_billing
    order = Order.new(
      payment_provider: payment_provider,
      placed_by: user,
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
      notes: params[:notes],
      delivery_fees: cart.market.is_consignment_market? && !params[:delivery_fees].nil? ? Float(params[:delivery_fees]) : cart.delivery_fees,
      total_cost: cart.market.is_consignment_market? && !params[:delivery_fees].nil? ? Float(params[:delivery_fees]) + cart.total : cart.total,
      placed_at: Time.current,
      order_type: cart.market.is_buysell_market? ? 'sales' : params[:order_type],
    )

    order.apply_delivery_address(cart.delivery_location)

    DeliveryNote.where(cart_id:cart.id).each do |dn|
      #binding.pry # there is no id available yet, it's not created
      dn.update_attributes(order_id:order.id)
    end

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
    DeliveryNote.where(cart_id:cart.id).each do |dn|
      dn.update_attributes(order_id:order.id)
    end
    order
  end

  def discount
    cart.discount if cart.has_valid_discount?
  end
end
