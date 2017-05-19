class ExportInvoiceToQb
  include Interactor

  def perform
    @qb_profile = curr_market.organization.qb_profile
    begin
      if curr_market.qb_integration_type.nil? || curr_market.qb_integration_type == 'invoice'
        result = Quickbooks::Invoice.create_invoice(order, session, @qb_profile)
      else
        result = Quickbooks::JournalEntry.create_journal_entry(order, session, @qb_profile)
      end

      if Integer(result.id) > 0
        order.qb_ref_id = Integer(result.id)
        order.save!

        if order.payment_method == "credit card" && (curr_market.qb_integration_type.nil? || curr_market.qb_integration_type == 'invoice')
          result = Quickbooks::Payment.create_payment(order, session)
        end
      end
    rescue => e
      puts e
      context.fail!
    end
  end
end