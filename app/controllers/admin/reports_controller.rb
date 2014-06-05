class Admin::ReportsController < AdminController
  before_action :require_admin_or_market_manager, except: :index
  before_action :find_order_items

  def index
    redirect_to [:admin, :reports, :total_sales]
  end

  def total_sales
    respond_to do |format|
      format.html do
        @q = @order_items.search(params[:q])
        @q.sorts = "created_at desc" if @q.sorts.empty?
        @markets = Market.for_order_items(@order_items)
        @order_items = @q.result.page(params[:page]).per(params[:per_page])
      end

      format.csv  { @filename = "report.csv"}
    end
  end

  private

  def find_order_items
    @order_items ||= OrderItem.for_user(current_user).joins(:order)
  end
end
