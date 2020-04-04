class AddItemsToOrder
  include Interactor

  def perform
    ActiveRecord::Base.transaction do
      delivery = order.delivery
      if cart.items.length > 0
        cart.items.each do |cart_item|
          if cart_item.quantity > 0
            order.add_cart_item(cart_item, delivery.deliver_on)
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
