class ExportInvoiceToQb
  include Interactor

  def perform
    @qb_profile = curr_market.organization.qb_profile
    begin
      result = Quickbooks::Invoice.create_invoice(order, session, @qb_profile)
      if Integer(result.id) > 0
        order.qb_ref_id = Integer(result.id)
        order.save!

        if order.payment_method == "credit card"
          result = Quickbooks::Payment.create_payment(order, session)
        end
      end
    rescue => e
      puts e
      context.fail!
    end
  end
end