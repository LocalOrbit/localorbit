class RemoveConsignmentOrder
  include Interactor::Organizer

  def perform
    if order.purchase_order?
      # When removing a PO, need to remove the associated SOs first
      Inventory::Utils.remove_po(order)
    else
      Inventory::Utils.remove_so(order)
    end
  end
end