module Invoices
  class InvoiceHeaderParamsGenerator
    class << self
      def generate_header_params(invoice, market)
        {
          logo_stored: market.logo_stored?,
          thumb_url: (market.logo_stored?) ? market.logo.thumb('200x150').url : nil,
          name: market.name,
          has_address: market.has_address?,
          street_address: (market.has_address?) ? market.billing_address : nil,
          city_state_zip: (market.has_address?) ? market.billing_city_state_zip : nil,
          display_contact_phone: (market.billing_address) ? market.billing_address_phone_number : nil,
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
          due_date: (invoice.invoice_due_date || market.po_payment_term.to_i.days.from_now).strftime("%-m/%-d/%Y"),
          date: (invoice.invoiced_at || Date.current).strftime("%-m/%-d/%Y")
        }.to_query
      end
    end
  end
end