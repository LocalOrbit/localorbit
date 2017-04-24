class CreateConsignmentTransaction
  include Interactor

  def perform

    return unless order.market.is_consignment_market?

    order.items.each do |item|

      po_order = nil
      check_existing = ConsignmentTransaction.where(market_id: order.market.id, transaction_type: order.sales_order? ? 'SO' : 'PO', order_id: order.id, product_id: item.product.id).first
      if !item.lots.first.nil?
        po_order = ConsignmentTransaction.joins("JOIN orders ON orders.id = consignment_transactions.order_id").where(transaction_type: 'PO', product_id: item.product_id, lot_id: item.lots.first.lot.id).where("orders.sold_through = 'f'").order(:created_at).last
      end

      ct = nil
      if check_existing.nil?
        ct = ConsignmentTransaction.create(
          market_id: order.market.id,
          transaction_type: order.sales_order? ? 'SO' : 'PO',
          order_id: order.id,
          order_item_id: item.id,
          lot_id: order.sales_order? && !item.lots.empty? ? item.lots.first.lot_id : nil,
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
        po_order.update_attributes(lot_id: item.lots.first.lot_id)
      end

      if holdover || repack
        context[:transaction_id] = !ct.nil? ? ct.id : nil
      end

    end
  end
end