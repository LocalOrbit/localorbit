module Admin::Financials
  class SellerPaymentsController < AdminController
    before_action :require_admin

    def index
      auto_market_ids = Market.joins(:plan).where(plans: {name: "Automate"}).select(:id)
      orders = Order.payable_to_sellers.paid.used_lo_payment_processing.where("placed_at > ?", 6.months.ago).where(market_id: auto_market_ids).preload(:items, :organization)
      @groups = SellerPaymentGroup.for_scope(orders).sort_by(&:name)
    end

    def create
      @pay_seller = PaySellerForOrders.perform(seller_id: params[:seller_id], bank_account_id: params[:bank_account_id], order_ids: params[:order_ids])

      if @pay_seller.success?
        redirect_to admin_financials_seller_payments_path, notice: "Payment recorded"
      else
        redirect_to admin_financials_seller_payments_path, alert: "Payment failed"
      end
    end
  end
end
