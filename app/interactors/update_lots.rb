class UpdateLots
  include Interactor
  def perform
    return unless order.purchase_order?

    lot_number = Inventory::Utils.generate_lot_number(order)

    order.items.each do |item|
      if !item.lots.first.nil?
        lot_number = item.lots.first.lot.number
      end
      if !item.quantity_delivered.nil?
        lot = Inventory::Utils.upsert_lot(item.product, lot_number, item.quantity_delivered)
        lot.update_attribute(:storage_location_id, item.preferred_storage_location_id) unless lot.storage_location_id == item.preferred_storage_location_id
        if !item.quantity_delivered.nil?
          update_pending_so(item, lot)
        end
      end
    end
  end

  def update_pending_so(item, lot)
    # When SO has been placed against undelivered PO, and PO is delivered, the newly created lot needs to be assigned to the SO consignment transaction
    ct_po = ConsignmentTransaction.where(transaction_type: 'PO', order_id: order.id, product_id: item.product.id, lot_id: nil).visible.last
    ct_so = ConsignmentTransaction.where(transaction_type: 'SO', parent_id: nil, product_id: item.product.id, lot_id: nil).visible

    ct_so.each do |so|
      so_order_item = OrderItem.find(so.order_item_id)
      so_order_item.lots << OrderItemLot.create(order_item_id: so_order_item.id, lot_id: lot.id, quantity: so.quantity)
      so_order_item.po_lot_id = lot.id
      so_order_item.save

      so.lot_id = lot.id
      if so.parent_id.nil?
        so.parent_id = ct_po.id
      end
      so.save
      lot.quantity = lot.quantity - so.quantity
      lot.save
    end
    if !ct_po.nil?
      ct_po.lot_id = lot.id
      ct_po.save
    end

  end
end
