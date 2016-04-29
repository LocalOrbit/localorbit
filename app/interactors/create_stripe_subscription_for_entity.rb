class CreateStripeSubscriptionForEntity
  include Interactor

  # This serves to prepare for perform AND document the expected context elements
  def setup
    token       ||= context[:market_params][:stripe_tok]
    sub_params  ||= context[:subscription_params]
    entity      ||= context[:entity]
    stripe_cust ||= context[:stripe_customer]
  end

  def perform
    # Initialize
    customer = PaymentProvider::Stripe.get_stripe_customer(stripe_cust.id)

    # Create the subscription
    subscription = PaymentProvider::Stripe.upsert_subscription(entity, customer, stripe_subscription_info)
    context[:subscription] = subscription
    # Update the entity (if it's a Market)
    entity.set_subscription(subscription) if entity.respond_to?(:set_subscription)

    # Capture the invoices...
    invoices = PaymentProvider::Stripe.get_stripe_invoices(:customer => subscription.customer)
    # ... and grab the most recent one
    context[:invoice] = invoices.data.first

  rescue => e
    context.fail!(error: e.message)
  end

  def stripe_subscription_info
    ret_val = {
      plan: sub_params[:plan],
      metadata: {
        "lo.entity_id" => entity.id,
        "lo.entity_type" => entity.class.name.underscore
      }
    }
    # Stripe uses the default card if one exists, but RYO (at least) will provide the stripe token
    ret_val[:source] = token if token.present?
    
    # Stripe complains if you pass an empty coupon.  Only add it if it exists
    ret_val[:coupon] = sub_params[:coupon] if sub_params[:coupon].present?
  end
end
