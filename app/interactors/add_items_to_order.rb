class AddItemsToOrder
  include Interactor

  def perform
    ActiveRecord::Base.transaction do
      delivery = order.delivery
      cart.items.each do |cart_item|
        order.add_cart_item(cart_item, delivery.deliver_on)
      end

      unless order.save
        fail!
        raise ActiveRecord::Rollback
      end
    end

    order
  end
end
