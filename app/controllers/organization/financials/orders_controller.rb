class Organization::Financials::OrdersController < ApplicationController
  def show
    @order = BuyerOrder.find(current_user, params[:id])
  end
end
