module Admin::Financials
  class SellerPaymentGroupsController < AdminController
    before_action :require_admin_or_market_manager

    layout false

    def show
      seller = Organization.find(params[:seller_id])
      seller_orders = Search::SellerOrderFinder.new(seller: seller, query: params).orders
      seller_payment_group = SellerPaymentGroup.new(seller, seller_orders)
      render :show, locals: {seller_payment_group: seller_payment_group}
    end

  end
end
