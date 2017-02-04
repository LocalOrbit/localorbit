class CreateSupplierOrgForProducer
  include Interactor

  def perform
    if market.organization.plan.stripe_id == "PRODUCER"
      organization_params = context[:organization].as_json

      org = Organization.new(organization_params.slice(:id).merge(name: "#{organization_params['name']} Supplier", active: true, allow_purchase_orders: true, allow_credit_cards: true, can_sell: true, org_type: 'S'))
      market.organizations << org
    else
      context.fail!
    end
  end
end