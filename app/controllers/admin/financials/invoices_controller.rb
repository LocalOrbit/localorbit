module Admin::Financials
  class InvoicesController < AdminController
    include StickyFilters

    before_action :find_orders_for_invoicing, only: [:create, :resend]
    before_action :find_sticky_params, only: :index


    def index
      if params["clear"]
        redirect_to url_for(params.except(:clear))
      else
        base_scope, date_filter_attr = find_base_scope_and_date_filter_attribute

        @search_presenter = OrderSearchPresenter.new(@query_params, current_user, date_filter_attr, true)
        @q = filter_and_search_orders(base_scope, @query_params, @search_presenter)

        @orders = @q.result.page(params[:page]).per(@query_params[:per_page])

        track_event EventTracker::ViewedInvoices.name
      end
    end

    def show
      @order = BuyerOrder.new(Order.find(params[:id]))
    end

    def create
      case params[:invoice_list_batch_action]
      when "send-selected-invoices"
        @orders.uninvoiced.each do |order|
          CreateInvoice.perform(order: order,
                                request: RequestUrlPresenter.new(request))
        end
        message = mk_order_number_message what: "Invoice sent", orders: @orders
        redirect_to admin_financials_invoices_path, notice: message

      when "preview-selected-invoices"
        context = InitializeBatchInvoice.perform(user: current_user, orders: @orders)
        if context.success?
          batch_invoice = context.batch_invoice
          GenerateBatchInvoicePdf.delay.perform(batch_invoice: batch_invoice,
                                                request: RequestUrlPresenter.new(request))
          track_event EventTracker::PreviewedBatchInvoices.name, num_invoices: @orders.count 
          redirect_to admin_financials_batch_invoice_path(batch_invoice)
        else
          redirect_to admin_financials_invoices_path, alert: context.message
        end

      when "mark-selected-invoiced"
        if @orders.empty?
          redirect_to admin_financials_invoices_path, alert: "Please select one or more invoices to mark"
        else
          results = Orders::Invoicing.mark_orders_invoiced(orders: @orders)
          if results[:status] == :failed
            logger.tagged("INVOICE_ERROR - #{self.class.name}") do
              logger.error("While marking orders as invoiced, something didn't go perfectly.\n#{results.inspect}")
            end
          end
        
          message = mk_order_number_message what: "Invoice marked", orders: @orders

          redirect_to admin_financials_invoices_path, notice: message
        end

      when nil, ""
        redirect_to admin_financials_invoices_path, alert: "No action provided."

      else
        redirect_to admin_financials_invoices_path, alert: "Unsupported action: '#{params[:invoice_list_batch_action]}'"

      end
    end

    def resend
      resend_invoices_and_redirect
    end

    def resend_overdue
      @orders = Order.so_orders.orders_for_seller(current_user).payment_overdue
      resend_invoices_and_redirect
    end

    private

    def find_base_scope_and_date_filter_attribute
      if current_user.buyer_only?
        [Order.so_orders.orders_for_buyer(current_user).invoiced, :invoice_due_date]
      else
        [Order.so_orders.orders_for_seller(current_user).uninvoiced, :placed_at]
      end
    end

    def find_orders_for_invoicing
      @orders = Order.so_orders.orders_for_seller(current_user).where(id: params[:order_id])
    end

    def filter_and_search_orders(scope, params, presenter)
      query = scope.periscope(params).search(presenter.query)
      query.sorts = ["invoice_due_at desc", "order_number asc"] if query.sorts.empty?
      query
    end

    def resend_message(orders)
      if orders.present?
        "Invoice resent for order #{"number".pluralize(orders.size)} #{orders.map(&:order_number).sort.join(", ")}."
      else
        "No overdue invoices found."
      end
    end

    def resend_invoices_and_redirect
      @orders.each {|order| SendInvoiceEmail.perform(order: order) }

      redirect_path = params[:redirect_to] || admin_financials_invoices_path
      redirect_to redirect_path, notice: resend_message(@orders)
    end

    def mk_order_number_message(what:,orders:)
      "#{what} for order #{"number".pluralize(orders.size)} #{orders.map(&:order_number).sort.join(", ")}. Invoices can be downloaded on the Enter Receipts page"
    end
  end
end
