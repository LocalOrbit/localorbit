module Admin::Financials
  class InvoicesController < AdminController
    def index
      @search_presenter = InvoiceSearchPresenter.new(request.query_parameters)

      @q = if current_user.buyer_only?
        Order.orders_for_buyer(current_user).invoiced
      else
        Order.orders_for_seller(current_user).uninvoiced
      end.search(request.query_parameters[:q])

      #@q.sorts = ['placed_at desc'] if @q.sorts.empty?
      @orders = @q.result.page(params[:page]).per(params[:per_page])
    end

    def show
      @order = BuyerOrder.new(Order.find(params[:id]))
    end

    def create
      orders = Order.orders_for_seller(current_user).uninvoiced.where(id: params[:order_id])
      # TODO: Figure out what to do if the save fails
      # The order would have to become invalid after being placed.
      orders.each {|order| SendInvoice.perform(order: order) }
      message = "Invoice sent for order #{"number".pluralize(orders.size)} #{orders.map(&:order_number).sort.join(', ')}. Invoices can be downloaded on the Enter Receipts page"
      redirect_to admin_financials_invoices_path, notice: message
    end

  end
end
