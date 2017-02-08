class PurchaseOrderPolicy < ApplicationPolicy

  def create?
    # KXM GC: policy PurchaseOrder#create? should confirm that market.organization.try(:payment_model) == 'consignment'
    # binding.pry

    true
    # market.organization.try(:payment_model) == 'consignment'
  end

end