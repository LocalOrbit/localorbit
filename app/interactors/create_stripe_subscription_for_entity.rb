class CreateStripeSubscriptionForEntity
  include Interactor

  def perform
    # Initialize
    subscription_params = context[:subscription_params]
    entity = context[:entity]
    customer = PaymentProvider::Stripe.get_stripe_customer(context[:stripe_customer].id)

    subscription = PaymentProvider::Stripe.upsert_subscription(entity, customer, stripe_subscription_info)
    context[:subscription] = subscription
    entity.set_subscription(subscription) if entity.respond_to?(:set_subscription)

    invoices = PaymentProvider::Stripe.get_stripe_invoices(:customer => subscription.customer) 
    context[:invoice] = invoices.data[0]
    
  rescue => e
    context.fail!(error: e.message)
  end

  def stripe_subscription_info
    ret_val = {
      plan: subscription_params[:plan],
      source: market_params[:stripe_tok],
      metadata: {
        "lo.entity_id" => entity.id,
        "lo.entity_type" => entity.class.name.underscore
      }
    }
    # Stripe complains if you pass an empty coupon.  Only add it if it exists 
    ret_val.tap do |r|
      r[:coupon] = subscription_params[:coupon] if !subscription_params[:coupon].blank?
    end
  end
end
