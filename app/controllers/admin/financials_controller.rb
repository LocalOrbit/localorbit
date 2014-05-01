class Admin::FinancialsController < AdminController
  def index
    if current_user.admin? || current_user.market_manager?
      redirect_to [:admin, :financials, :payments]
    elsif
      redirect_to [:admin, :financials, :overview]
    end
  end
end
