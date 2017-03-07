class ExportBillToQb
  include Interactor

  def perform
    @qb_profile = curr_market.organization.qb_profile
    result = Quickbooks::Bill.create_bill(order, session, @qb_profile)
    order.qb_ref_id = Integer(result.id)
    order.save!
  end
end