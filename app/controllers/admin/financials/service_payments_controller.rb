class Admin::Financials::ServicePaymentsController < AdminController
  before_action :require_admin

  def index
    @markets = Market.active.sort_service_payment.reject{|m| m.organization.adjunct_organization == true}.map(&:decorate)
  end

  def create
    market = Market.find(params[:market_id])
    organization = Organization.find(params[:organization_id])
    results = ChargeServiceFee.perform(entity: organization, subscription_params: {plan: organization.plan.stripe_id}, flash: flash)

    if results.success?
      organization.subscribe!
      organization.set_subscription(results.subscription)

      notice = "Subscription created for #{market.name}.  Payment to be processed shortly"
    else
      notice = results.context[:error] || "Subscription creation failed for #{market.name}"
    end

    redirect_to admin_financials_service_payments_path, notice: notice
  end
end
