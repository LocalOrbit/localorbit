class AddItemsToOrder
  include Interactor

  def perform
    ActiveRecord::Base.transaction do
      delivery = order.delivery
      if cart.items.length > 0
        cart.items.each do |cart_item|
          if order.market.is_consignment_market? && order.items.map(&:po_lot_id).include?(cart_item.lot_id) && cart_item.quantity > 0
            order.items.each do |oi|
              if oi.po_lot_id == cart_item.lot_id
                oi.quantity = oi.quantity + cart_item.quantity
                oi.save
              end
            end
          else
            if cart_item.quantity > 0
              order.add_cart_item(cart_item, delivery.deliver_on)
            end
          end
        end
      end

      unless order.save
        fail!
        raise ActiveRecord::Rollback
      end
    end

    order
  end
end
