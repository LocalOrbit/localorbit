module Admin
  class InvoicesController < AdminController
    before_action :fetch_order

    def show
      #ClearInvoicePdf.perform(order: @order)
      if @order.invoice_pdf.present?
        redirect_to @order.invoice_pdf.remote_url
      else
        GenerateInvoicePdf.delay.perform(order: @order,
                                 pre_invoice: true,
                                 request: RequestUrlPresenter.new(request))
        redirect_to action: :await_pdf
      end

    end

    def await_pdf
      respond_to do |format|
        format.html {}
        format.json do
          status = if @order.invoice_pdf.present?
                     { pdf_url: @order.invoice_pdf.remote_url }
                   else
                     { pdf_url: nil }
                   end
          render json: status
        end
      end
    end

    # Secret: peek at an HTML version of the Invoice
    def peek
      @invoice = BuyerOrder.new(@order)
      @market  = @invoice.market.decorate
      @needs_js = true

      @header_params = Invoices::InvoiceHeaderParamsGenerator.generate_header_params(@invoice, @market)
      render "show", layout: false, locals: { invoice: @invoice, user: current_user, header_params: @header_params }
    end

    private

    def fetch_order
      @order = if current_user.admin? || current_user.market_manager?
        Order.orders_for_buyer(current_user).find(params[:id])
      else
        Order.orders_for_buyer(current_user).invoiced.find(params[:id])
      end
    end
  end
end
