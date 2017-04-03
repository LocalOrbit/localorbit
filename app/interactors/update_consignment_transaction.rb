class UpdateConsignmentTransaction
  include Interactor

  def perform

    return unless order.market.is_consignment_market?

    if order.market.is_consignment_market?
      order.items.each do |item|
        check_existing = ConsignmentTransaction.where(market_id: order.market.id, transaction_type: order.sales_order? ? 'SO' : 'PO', order_id: order.id, order_item_id: item.id).first
        if !item.quantity_delivered.nil?
          check_existing.update_attributes!(quantity: item.quantity_delivered)
        else
          check_existing.update_attributes!(quantity: item.quantity)
        end
      end
    end
  end
end