class CartDecorator < Draper::Decorator
  delegate_all

  def display_subtotal
    "$%.2f" % subtotal
  end

  def display_delivery_fees
    return "Free!" if delivery.delivery_schedule.free_delivery?
    
    "$%.2f" % delivery_fees
  end
end
