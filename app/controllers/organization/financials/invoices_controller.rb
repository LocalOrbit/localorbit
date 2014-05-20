class Organization::Financials::InvoicesController < ApplicationController
  def index
    @invoices = Order.orders_for_buyer(current_user).invoiced
  end

  def show
    @invoice = BuyerOrder.new(Order.find(params[:id]))
  end
end
