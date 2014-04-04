class OrderItemDecorator < Draper::Decorator
  delegate_all

  def quantity_with_unit
    "#{quantity} #{unit}"
  end
end
