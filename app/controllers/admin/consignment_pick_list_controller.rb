module Admin
  class ConsignmentPickListController < AdminController
    before_action :fetch_orders

    def show
      if Rails.env == "development"
        generate_development_pdf
      else
        generate_production_pdf
      end
    end

    def generate_development_pdf
      GenerateConsignmentPickListPdf.perform(orders: @orders,
                                 request: RequestUrlPresenter.new(request))
      redirect_to action: :await_pdf
    end

    def generate_production_pdf
      GenerateConsignmentReceiptPdf.delay(queue: :urgent).perform(order: @orders,
                                       request: RequestUrlPresenter.new(request))
      redirect_to action: :await_pdf
    end

    def await_pdf
      respond_to do |format|
        format.html {}
        format.json do
          status = if picklist_pdf.present?
                     { pdf_url: picklist_pdf.remote_url }
                   else
                     { pdf_url: nil }
                   end
          render json: status
        end
      end
    end

    # Secret: peek at an HTML version of the Invoice
    def peek
      @market  = current_market.decorate
      @needs_js = true

      render "show", layout: false, locals: { orders: @orders, market: @market, user: current_user }
    end

    private

    def fetch_orders
      @orders =  Order.so_orders.orders_for_buyer(current_user).find(params[:id])
    end
  end
end
