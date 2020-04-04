module Admin
  class InvoicesController < AdminController
    before_action :fetch_order

    def show
      ClearInvoicePdf.perform(order: @order)
      GenerateInvoicePdf.delay(queue: :urgent).perform(order: @order,
                                       pre_invoice: true,
                                       request: RequestUrlPresenter.new(request))
      redirect_to action: :await_pdf
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

      render "show", layout: false, locals: { invoice: @invoice, market: @market, user: current_user }
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
