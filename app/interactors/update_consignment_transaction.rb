class UpdateConsignmentTransaction
  include Interactor

  def perform

    return unless order.market.is_consignment_market?

    if order.market.is_consignment_market?
      if item.nil?
        order.items.each do |item|
          if order.sales_order?
            check_existing = ConsignmentTransaction.where(market_id: order.market.id, transaction_type: order.sales_order? ? 'SO' : 'PO', order_id: order.id, order_item_id: item.id).first
          end
          if !item.quantity_delivered.nil?
            check_existing.update_attributes!(quantity: item.quantity_delivered, sale_price: item.unit_price, net_price: item.net_price)
          else
            check_existing.update_attributes!(quantity: item.quantity, sale_price: item.unit_price, net_price: item.net_price)
          end
        end
      else
        if order.sales_order?
          check_existing = ConsignmentTransaction.where(market_id: order.market.id, transaction_type: order.sales_order? ? 'SO' : 'PO', order_id: order.id, order_item_id: item.id).first
        end
        if !item.quantity_delivered.nil?
          check_existing.update_attributes!(quantity: item.quantity_delivered, sale_price: item.unit_price, net_price: item.net_price)
        else
          check_existing.update_attributes!(quantity: item.quantity, sale_price: item.unit_price, net_price: item.net_price)
        end
      end

    end
  end
end