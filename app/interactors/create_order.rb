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

  protected

  def check_order_for_je_limit(cart)
    entry_count = 3
    entry_count = entry_count + cart.items.map(&:product).map(&:organization_id).uniq.count
    if entry_count > 100
      context.fail!('Number of suppliers on order exceeds journal entry limit. Please split order.')
    end
  end

  def create_order_from_cart(params, cart, user)
    billing = cart.organization.locations.default_billing
    order = Order.new(
      payment_provider: payment_provider,
      placed_by: user,
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
      delivery_fees: cart.delivery_fees,
      total_cost: cart.total,
      placed_at: Time.current,
    )

    order.apply_delivery_address(cart.delivery_location)

    success = false
    ActiveRecord::Base.transaction do
      # in the transaction because it updates sequences table
      order.order_number = OrderNumber.new(cart.market).id

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

    if success
      DeliveryNote.where(cart_id: cart.id).each do |dn|
        dn.update_attributes(order_id: order.id)
      end
    end

    order
  end

  def discount
    cart.discount if cart.has_valid_discount?
  end
end
