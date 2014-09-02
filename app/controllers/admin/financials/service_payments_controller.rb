class Admin::Financials::ServicePaymentsController < AdminController
  before_action :require_admin

  def index
    @markets = Market.active.sort_service_payment
  end

  def create
    market = Market.find(params[:market_id])
    charge = ChargeServiceFee.perform(market: market, amount: market.plan_fee, bank_account: market.plan_bank_account)
    if charge.success?
      redirect_to admin_financials_service_payments_path, notice: "Payment made for #{market.name}"
    else
      redirect_to admin_financials_service_payments_path, notice: "Payment failed for #{market.name}"
    end
  end
end
