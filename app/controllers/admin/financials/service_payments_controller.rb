class Admin::Financials::ServicePaymentsController < AdminController
  before_action :require_admin

  def index
    @markets = Market.active.sort_service_payment.map(&:decorate)
  end

  def create
    # Retrieve the market
    market = Market.find(params[:market_id])
    card = nil

    # If the market is a Stripe customer...
    if customer = market.stripe_customer #PaymentProvider::Stripe.get_stripe_customer(market.stripe_customer_id)
    # if market.stripe_customer_id?
      # ...then retrieve Stripe customer

      # Retrieve card (if card exists)
      # First, capture the default card if it exists
      card = customer.default_source if customer.try(:default_source)

      # If not, then cycle through the cards...
      if card.nil?
        customer.sources.data.each do |source|
          # ...grabbing the first credit card that exists
          card = source if source.object = 'card'
          break if source.object = 'card'
        end
      end

      # Build the subscription hash
      stripe_subscription_data = {
        plan: market.plan.stripe_id,
        source: card,
        metadata: {
          "lo.entity_id" => market.id,
          "lo.entity_type" => market.class.name.underscore
        }
      }
      
      # This is disabled for now...
      # Stripe complains if you pass an empty coupon.  Only add it if it exists
      # stripe_subscription_data[:coupon] = subscription_params[:coupon] if !subscription_params[:coupon].blank?

      # Finally, create the subscription
      subscription = customer.subscriptions.create(stripe_subscription_data)

    else
      # If the market is NOT a Stripe customer then alert accordingly
      redirect_to admin_financials_service_payments_path, notice: "#{market.name} is not yet a Stripe customer"

    end

    if subscription.nil?
      redirect_to admin_financials_service_payments_path, notice: "Failed to create subscription for #{market.name}"
    else
      #binding.pry
      payment = CreateServicePayment.perform(market: market, amount: 500, bank_account: market.bank_accounts.first)
      if payment.success?
        redirect_to admin_financials_service_payments_path, notice: "Subscription to #{market.plan.name} created for #{market.name}"
      else
        redirect_to admin_financials_service_payments_path, notice: "Failed to create payment record for new subscription for #{market.name}"
      end
    end
  end
end
