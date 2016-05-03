class CreateStripeSubscriptionForEntity
  include Interactor

  def perform
    # Initialize
    market_params ||= context[:market_params]
    sub_params    ||= context[:subscription_params]
    entity        ||= context[:entity]

    token = market_params.try(:stripe_tok)

    # Create the subscription...
    subscription = PaymentProvider::Stripe.upsert_subscription(entity, stripe_subscription_info(sub_params, entity, token))
    context[:subscription] = subscription
    # ...update the entity (if it's a Market)...
    entity.set_subscription(subscription) if entity.respond_to?(:set_subscription)

    # ...and populate the context with resultant data
    invoices = PaymentProvider::Stripe.get_stripe_invoices(:customer => subscription.customer)
    context[:invoice] = invoices.data.first
    context[:amount] ||= amount = ::Financials::MoneyHelpers.cents_to_amount(subscription.plan.amount)
    context[:bank_account_params] = PaymentProvider::Stripe.glean_card(context[:invoice])

  rescue => e
    context.fail!(error: e.message)
  end

  def stripe_subscription_info(sub_params, entity, token)
    ret_val = {
      # 'plan' here refers to the Stripe plan ID...
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

    # Return the return value
    ret_val
  end
end
