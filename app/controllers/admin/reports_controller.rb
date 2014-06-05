class Admin::ReportsController < AdminController
  before_action :restrict_buyer_only
  before_action :find_order_items
  before_action :setup_search

  def index
    redirect_to [:admin, :reports, :total_sales]
  end

  def total_sales
    respond_to do |format|
      format.html do
        @markets = Market.for_order_items(@order_items)
        @order_items = @q.result.page(params[:page]).per(params[:per_page])
      end

      format.csv  { @filename = "report.csv"}
    end
  end

  private

  def restrict_buyer_only
    render_404 if current_user.buyer_only?
  end

  def find_order_items
    @order_items ||= OrderItem.for_user(current_user).joins(:order)
  end

  def setup_search
    @q = @order_items.search(params[:q])
    @q.sorts = "created_at desc" if @q.sorts.empty?
  end
end
