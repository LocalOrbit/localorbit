module Admin
  class InvoicesController < AdminController
    before_action :fetch_order

    def show

      ClearInvoicePdf.perform(order: @order)
      if @order.invoice_pdf.present?
        redirect_to @order.invoice_pdf.remote_url
      else
        GenerateInvoicePdf.perform(order: @order,
                                 pre_invoice: true,
                                 request: RequestUrlPresenter.new(request))
        #GenerateInvoicePdf.delay.perform(order: @order,
        #                                 pre_invoice: true,
        #                                 request: RequestUrlPresenter.new(request))
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

      market = @market
      invoice = @invoice

      @header_params = {
        logo_stored: market.logo_stored?,
        thumb_url: market.logo.thumb('200x150>').url,
        name: market.name,
        has_address: market.has_address?,
        street_address: market.street_billing_address,
        city_state_zip: market.city_state_zip,
        display_contact_phone: market.display_contact_phone,
        contact_email: market.contact_email,
        billing_organization_name: invoice.billing_organization_name,
        billing_address: invoice.billing_address,
        billing_city: invoice.billing_city,
        billing_state: invoice.billing_state,
        billing_zip: invoice.billing_zip,
        order_number: invoice.order_number,
        delivery_date: invoice.delivery_date,
        delivery_date_present: invoice.delivery_date.present?,
        payment_note: invoice.payment_note,
        payment_note_present: invoice.payment_note.present?,
        due_date: (invoice.invoice_due_date || market.po_payment_term.to_i.days.from_now).strftime("%-m/%-d/%Y"),
        date: (invoice.invoiced_at || Date.current).strftime("%-m/%-d/%Y")
      }.to_query

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
