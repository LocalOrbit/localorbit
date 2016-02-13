class CreateStripeSubscriptionForEntity
  include Interactor

  def perform
    # Initialize
    found_flag = false
    local_customer = context[:stripe_customer]
    subscription_params = context[:subscription_params]

    entity = context[:entity]

    customer = Stripe::Customer.retrieve(local_customer.id)
    customer.source = market_params[:stripe_card_token]
    customer.save

    # If the customer has any subscriptions...
    if customer.subscriptions.data.any?
      # ...cycle through the subscriptions
      customer.subscriptions.data.each do |sub|
        # If any match the current data...
        if sub.plan.id = subscription_params[:plan]
          # ...then update the subscription...
          subscription        = customer.subscriptions.retrieve(sub.id)
          subscription.plan   = subscription_params[:plan]
          subscription.coupon = subscription_params[:coupon]
          subscription.source = subscription_params[:source]
          subscription.save

        else
          # KXM Wouldn't a new subscription require deleting ALL old subscriptions?  In our use, aren't plans mutually exclusive?  If so then uncomment the following line which deletes the non-matching subscription
          # customer.subscriptions.retrieve(sub.id).delete
        end
      end

    # Otherwise... 
    else
      # ...just create one
      subscription = customer.subscriptions.create(stripe_subscription_info)
    end

    context[:subscription] = subscription
  end

  def stripe_subscription_info
    {
      plan: subscription_params[:plan],
      coupon: subscription_params[:coupon],
      source: subscription_params[:stripe_card_token],
      metadata: {
        "lo.entity_id" => entity.id,
        "lo.entity_type" => entity.class.name.underscore
      }
    }
  end
end
