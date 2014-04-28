module Admin
  class InvoicesController < AdminController
    def show
      @invoice = BuyerOrder.new(Order.orders_for_buyer(current_user).invoiced.find(params[:id]))
      @market  = @invoice.market.decorate

      render layout: false
    end
  end
end
