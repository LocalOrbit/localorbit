class OrderItemDecorator < Draper::Decorator
  include ActionView::Helpers::NumberHelper

  delegate_all

  def quantity_with_unit
    "#{quantity} #{unit}"
  end

  def placed_at
    order.placed_at.strftime("%m/%d/%Y")
  end

  def price_per_unit
    "#{number_to_currency(unit_price)}/#{unit}"
  end
end
