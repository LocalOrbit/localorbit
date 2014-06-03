module Admin
  class InvoicesController < AdminController
    def show
      order = if current_user.admin? || current_user.market_manager?
        Order.orders_for_buyer(current_user).find(params[:id])
      else
        Order.orders_for_buyer(current_user).invoiced.find(params[:id])
      end

      @invoice = BuyerOrder.new(order)
      @market  = @invoice.market.decorate

      render layout: false
    end
  end
end
