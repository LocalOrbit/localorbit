module Admin
  class ConsignmentReceiptsController < AdminController
    before_action :fetch_order

    def show
      if Rails.env == "development"
        generate_development_pdf
      else
        generate_production_pdf
      end
    end

    def generate_development_pdf
      ClearConsignmentReceiptPdf.perform(order: @order)
      GenerateConsignmentReceiptPdf.perform(order: @order,
                                 request: RequestUrlPresenter.new(request))
      redirect_to action: :await_pdf
    end

    def generate_production_pdf
      ClearConsignmentReceiptPdf.perform(order: @order)
      GenerateConsignmentReceiptPdf.delay.perform(order: @order,
                                       request: RequestUrlPresenter.new(request))
      redirect_to action: :await_pdf
    end

    def await_pdf
      respond_to do |format|
        format.html {}
        format.json do
          status = if @order.receipt_pdf.present?
                     { pdf_url: @order.receipt_pdf.remote_url }
                   else
                     { pdf_url: nil }
                   end
          render json: status
        end
      end
    end

    # Secret: peek at an HTML version of the Invoice
    def peek
      @receipt = BuyerOrder.new(@order)
      @market  = @receipt.market.decorate
      @needs_js = true

      render "show", layout: false, locals: { receipt: @receipt, market: @market, user: current_user }
    end

    private

    def fetch_order
      @orders =  Order.po_orders.orders_for_buyer(current_user).find(params[:id])
    end
  end
end
