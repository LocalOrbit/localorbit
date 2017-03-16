class CreateConsignmentTransaction
  include Interactor

  def perform

    return unless order.market.is_consignment_market?

    order.items.each do |item|
      if order.sales_order?
        po_order = ConsignmentTransaction.where(transaction_type: 'PO', product_id: item.product_id, lot_id: item.lots.first.id).first
        if !po_order.nil?
          po_order.update_attributes(assoc_order_id: order.id, assoc_order_item_id: item.id, assoc_lot_id: item.lots.first.id, assoc_product_id: item.product_id)
        end
      end

      ct = ConsignmentTransaction.create(
        transaction_type: order.sales_order? ? 'SO' : 'PO',
        order_id: order.id,
        order_item_id: item.id,
        lot_id: order.sales_order? ? item.lots.first.id : nil,
        delivery_date: order.delivery.deliver_on,
        product_id: item.product_id,
        quantity: item.quantity
      )
      ct.save
    end
  end
end