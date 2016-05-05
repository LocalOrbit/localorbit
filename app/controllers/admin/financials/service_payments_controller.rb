class Admin::Financials::ServicePaymentsController < AdminController
  before_action :require_admin

  def index
    @markets = Market.active.sort_service_payment.map(&:decorate)
  end

  def create
    market  = Market.find(params[:market_id])

    results = ChargeServiceFee.perform(entity: market, subscription_params: {plan: market.plan.stripe_id}, flash: flash)

    if results.success?
      market.subscribe!
      market.set_subscription(results.invoice)

      notice = "Payment made for #{market.name}"
    else
      # KXM Should the subscription be revoked if the LO payment isn't created (I'm thinking yes...)?  If so, do it here, if not, then how do we reconcile LO and Stripe
      notice = results.context[:error] || "Payment failed for #{market.name}"
    end

    redirect_to admin_financials_service_payments_path, notice: notice
  end
end
