class Admin::Financials::ServicePaymentsController < AdminController
  before_action :require_admin

  def index
    @markets = Market.active.sort_service_payment.map(&:decorate)
  end

  def create
    market   = Market.find(params[:market_id])
    results = CreateStripeSubscriptionForEntity.perform(entity: market, subscription_params: {plan: market.plan.stripe_id})

    if results.success?
      # Mark the market as subscribed...
      market.subscribe!

      # ..and create a LO payment record
      amount = ::Financials::MoneyHelpers.cents_to_amount(results.subscription.plan.amount)
      payment = CreateServicePayment.perform(market: market, amount: amount, bank_account: market.bank_accounts.first, invoice: results.invoice)
      if payment.success?
        notice = "Subscription to #{market.plan.name} created for #{market.name}"
      else
        # KXM Should the subscription be revoked if the LO payment isn't created (I'm thinking yes...)?  If so, do it here, if not, then how do we reconcile LO and Stripe
        notice = "Failed to create payment record for new subscription for #{market.name}"
      end
    else
      notice = "Failed to create subscription to #{market.plan.name} for #{market.name}"
    end

    redirect_to admin_financials_service_payments_path, notice: notice
  end
end
