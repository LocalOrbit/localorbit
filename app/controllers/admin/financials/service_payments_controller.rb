class Admin::Financials::ServicePaymentsController < AdminController
  before_action :require_admin

  def index
    @organizations = Organization.active.sort_service_payment.map(&:decorate)
  end

  def create
    organization = Organization.find(params[:organization_id])
    charge = ChargeServiceFee.perform(organization: organization, amount: organization.plan_fee, bank_account: organization.plan_bank_account)
    if charge.success?
      redirect_to admin_financials_service_payments_path, notice: "Payment made for #{organization.name}"
    else
      redirect_to admin_financials_service_payments_path, notice: "Payment failed for #{organization.name}"
    end
  end
end
