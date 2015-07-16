module Invoices
  class InvoicePdfGenerator
    class << self
      def generate_pdf(request:,order:,path:nil)
        invoice = BuyerOrder.new(order)

        TemplatedPdfGenerator.generate_pdf(
          request: request,
          template: "admin/invoices/show",
          locals: {
            invoice: invoice,
            user: nil,
            header_params: header_params(invoice)
          },
          pdf_settings: { 
            page_size: "letter", 
            print_media_type: true
          },
          path: path
        )
      end

      def header_params(invoice)
        market  = invoice.market.decorate

        {
          logo_stored: market.logo_stored?,
          thumb_url: market.logo.thumb('200x150>').url,
          name: market.name,
          has_address: market.has_address?,
          street_address: market.billing_street_address,
          city_state_zip: market.billing_city_state_zip,
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
      end
    end
  end
end
