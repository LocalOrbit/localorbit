class Admin::FinancialsController < AdminController
  def index
    if current_user.admin?
      redirect_to [:admin, :financials, :invoices]
    elsif
      redirect_to [:admin, :financials, :overview]
    end
  end
end
