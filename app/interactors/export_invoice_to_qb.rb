class ExportInvoiceToQb
  include Interactor

  def perform
    @qb_profile = curr_market.organization.qb_profile
    begin
      result = Quickbooks::Invoice.create_invoice(order, session, @qb_profile)
      order.qb_ref_id = Integer(result.id)
      order.save!
    rescue => e
      context.fail!
    end
  end
end