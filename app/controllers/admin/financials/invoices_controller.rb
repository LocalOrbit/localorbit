module Admin::Financials
  class InvoicesController < AdminController
    def index
      base_scope = nil
      date_filter_attr = nil

      if current_user.buyer_only?
        base_scope = Order.orders_for_buyer(current_user).invoiced
        date_filter_attr = :invoice_due_date
      else
        base_scope = Order.orders_for_seller(current_user).uninvoiced
        date_filter_attr = :placed_at
      end

      @search_presenter = OrderSearchPresenter.new(request.query_parameters, current_user, date_filter_attr)
      @q = base_scope.periscope(request.query_parameters).search(@search_presenter.query)

      @q.sorts = ['invoice_due_at desc', 'order_number asc'] if @q.sorts.empty?
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
