class UpdateLots
  include Interactor
  def perform
    return unless order.purchase_order?

    lot_number = Inventory::Utils.generate_lot_number

    order.items.each do |item|
      lot = Inventory::Utils.upsert_lot(item.product, lot_number, item.quantity_delivered)
      update_pending_so(item, lot)
    end
  end

  def update_pending_so(item, lot)
    # When SO has been placed against undelivered PO, and PO is delivered, the newly created lot needs to be assigned to the SO consignment transaction
    ct_po = ConsignmentTransaction.where(transaction_type: 'PO', order_id: order.id, product_id: item.product.id).first
    ct_so = ConsignmentTransaction.where(transaction_type: 'SO', parent_id: ct_po.id, product_id: item.product.id)
    ct_so.each do |so|
      so.lot_id = lot.id
      so.save
      lot.quantity = lot.quantity - so.quantity
      lot.save
    end
  end
end
