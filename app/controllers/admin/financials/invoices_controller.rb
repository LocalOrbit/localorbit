module Admin::Financials
  class InvoicesController < AdminController
    include StickyFilters

    before_action :find_orders_for_invoicing

    def index
      if current_user.buyer_only?
        base_scope = Order.orders_for_buyer(current_user).invoiced
        date_filter_attr = :invoice_due_date
      else
        base_scope = Order.orders_for_seller(current_user).uninvoiced
        date_filter_attr = :placed_at
      end

      @query_params = sticky_parameters(request.query_parameters)
      @search_presenter = OrderSearchPresenter.new(@query_params, current_user, date_filter_attr)
      @q = base_scope.periscope(@query_params).search(@search_presenter.query)

      @q.sorts = ["invoice_due_at desc", "order_number asc"] if @q.sorts.empty?
      @orders = @q.result.page(params[:page]).per(@query_params[:per_page])
    end

    def show
      @order = BuyerOrder.new(Order.find(params[:id]))
    end

    def create
      # TODO: Figure out what to do if the save fails
      # The order would have to become invalid after being placed.
      @orders.uninvoiced.each {|order| CreateInvoice.perform(order: order) }

      message = "Invoice sent for order #{"number".pluralize(@orders.size)} #{@orders.map(&:order_number).sort.join(", ")}. Invoices can be downloaded on the Enter Receipts page"
      redirect_to admin_financials_invoices_path, notice: message
    end

    def resend
      @orders.each {|order| SendInvoiceEmail.perform(order: order) }

      message = "Invoice resent for order #{"number".pluralize(@orders.size)} #{@orders.map(&:order_number).sort.join(", ")}."
      redirect_path = params[:redirect_to] || admin_financials_invoices_path
      redirect_to redirect_path, notice: message
    end

    private

    def find_orders_for_invoicing
      @orders = Order.orders_for_seller(current_user).where(id: params[:order_id])
    end
  end
end
