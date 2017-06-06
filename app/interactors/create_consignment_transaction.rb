class CreateConsignmentTransaction
  include Interactor

  def perform

    return unless order.market.is_consignment_market?

    order.items.each do |item|

      po_order = nil
      if order.sales_order?
        check_existing = ConsignmentTransaction.where(market_id: order.market.id, transaction_type: 'SO', order_id: order.id, product_id: item.product.id, lot_id: item.po_lot_id).first
      else
        check_existing = ConsignmentTransaction.where(market_id: order.market.id, transaction_type: 'PO', order_id: order.id, product_id: item.product.id).first
      end
      
      if !item.po_ct_id.nil? && item.po_ct_id > 0
        po_order = ConsignmentTransaction.find(item.po_ct_id)

        #if po_order.nil? # Dealing with a split
        #  split_trans = ConsignmentTransaction.where(transaction_type: 'SPLIT', child_product_id: item.product_id, child_lot_id: !item.po_lot_id.nil? && item.po_lot_id > 0 ? item.po_lot_id : item.lots.first.lot.id).first
        #  if !split_trans.nil?
        #    po_order = ConsignmentTransaction.joins("JOIN orders ON orders.id = consignment_transactions.order_id").where(transaction_type: 'PO', product_id: split_trans.product_id, lot_id: split_trans.lot_id).where("orders.sold_through = 'f'").order(:created_at).last
        #  end
        #end
      end

      ct = nil
      if check_existing.nil?
        if order.sales_order? && !item.po_lot_id.nil? && item.po_lot_id > 0
          lt_id = item.po_lot_id
        else
          lt_id = nil
        end

        ct = ConsignmentTransaction.create(
            market_id: order.market.id,
            transaction_type: order.sales_order? ? 'SO' : 'PO',
            order_id: order.id,
            order_item_id: item.id,
            lot_id: lt_id,
            delivery_date: order.delivery.deliver_on,
            product_id: item.product_id,
            quantity: item.quantity,
            sale_price: item.unit_price,
            net_price: item.net_price,
            parent_id: order.sales_order? && !po_order.nil? ? po_order.id : nil
          )
          ct.save
          Audit.create!(user_id: user.id, action:"create", auditable_type: "ConsignmentTransaction", auditable_id: order.id, audited_changes: {'transaction_type' => order.sales_order? ? 'SO' : 'PO'})

      end


      if !po_order.nil? && order.sales_order? && po_order.lot_id.nil?
        po_order.update_attributes(lot_id: !item.po_lot_id.nil? ? item.po_lot_id : nil)
      end

      if holdover || repack
        context[:transaction_id] = !ct.nil? ? ct.id : nil
      end

    end
  end
end