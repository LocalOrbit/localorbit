module Admin::Financials
  class MarketPaymentsController < AdminController
    before_action :require_admin

    def index
      @orders_by_market = Order.balanced_payable.group_by(&:market).sort {|a,b| a.first.name <=> b.first.name }
    end

    def create
      @pay_market = PayMarketForOrders.perform(user: current_user, market_id: params[:market_id], bank_account_id: params[:bank_account_id], order_ids: params[:order_ids])
      if @pay_market.success?
        redirect_to :index, notice: "Payment recorded"
      else
        redirect_to :index, alert: "Payment failed"
      end
    end
  end
end
