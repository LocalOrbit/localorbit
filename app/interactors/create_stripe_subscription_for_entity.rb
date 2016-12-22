class CreateStripeSubscriptionForEntity
  include Interactor

  def perform
    market_params ||= context[:market_params]
    sub_params    ||= context[:subscription_params]

    entity = context[:RYO] == true ? context[:organization] : context[:entity]
    original_entity = entity.dup

    token = market_params && market_params[:stripe_tok]

    # Create the subscription...
    subscription = PaymentProvider::Stripe.upsert_subscription(entity, stripe_subscription_info(sub_params, entity, token))
    context[:subscription] = subscription

    # ...update the entity
    entity.set_subscription(subscription) if entity.respond_to?(:set_subscription)

  rescue => e
    context.fail!(error: e.message)

    # If the context fails then roll back the subscription (if any)
    PaymentProvider::Stripe.delete_stripe_subscription(subscription.id) if subscription.present?
    entity.unset_subscription(original_entity) if entity.respond_to?(:unset_subscription)
  end

  def stripe_subscription_info(sub_params, entity, token)
    ret_val = {
      # 'plan' here refers to the Stripe plan ID...
      plan: sub_params[:plan],
      metadata: {
        "lo.entity_id" => entity.id,
        "lo.entity_type" => entity.class.name.underscore,
        "lo_entity_id" => entity.id,
        "lo_entity_name" => entity.name,
        "lo_entity_type" => entity.class.name.underscore
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
