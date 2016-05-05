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
      market.set_subscription(results.invoice)

      bank_account = BankAccount.find_by stripe_id: results.bank_account_params.id  if results.bank_account_params.class == Stripe::Card
      bank_account = market.bank_accounts.first if bank_account.nil?

      # ..and create a LO payment record
      amount = ::Financials::MoneyHelpers.cents_to_amount(results.invoice.amount_due)
      payment = CreateServicePayment.perform(market: market, amount: amount, bank_account: bank_account, invoice: results.invoice)
      if payment.success?
        notice = "Payment made for #{market.name}"
        # notice = "Payment made for #{market.name} (now subscribed to #{market.plan.name} plan)"
        # notice = "Subscription to #{market.plan.name} created for #{market.name}"
      else
        # KXM Should the subscription be revoked if the LO payment isn't created (I'm thinking yes...)?  If so, do it here, if not, then how do we reconcile LO and Stripe
        notice = "Payment failed for #{market.name}"
      end
    else
      notice = "Payment failed for #{market.name}"
    end

    redirect_to admin_financials_service_payments_path, notice: notice
  end
end
