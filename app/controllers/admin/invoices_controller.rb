module Admin
  class InvoicesController < AdminController
    before_action :fetch_order

    def show
      @invoice = BuyerOrder.new(@order)
      @market  = @invoice.market.decorate
      @needs_js = true

      render layout: false, locals: { invoice: @invoice, user: current_user }
    end

    def show_pdf
      if @order.invoice_pdf.present?
        redirect_to @order.invoice_pdf.remote_url
      else
        GenerateInvoicePdf.delay.perform(order: @order,
                                         request: RequestUrlPresenter.new(request))
        render "generating"
      end
    end

    def mark_invoiced
      @order.invoice
      head @order.save ? :ok : :not_found
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
