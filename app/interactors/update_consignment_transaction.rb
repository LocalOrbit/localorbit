class UpdateConsignmentTransaction
  include Interactor

  def perform

    return unless order.market.is_consignment_market?

    order.items.each do |item|

      ct = ConsignmentTransaction.where(market_id: order.market.id, transaction_type: order.sales_order? ? 'SO' : 'PO', order_id: order.id, product_id: item.product.id, lot_id: order.sales_order? && !item.lots.empty? ? item.lots.first.id : nil)

      if !ct.empty?
        ct[0].update_attributes(quantity: item.quantity_delivered)
      end
    end
  end
end