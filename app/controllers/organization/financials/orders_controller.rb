class Organization::Financials::OrdersController < OrganizationController
  def show
    @order = BuyerOrder.find(current_user, params[:id])
  end
end
