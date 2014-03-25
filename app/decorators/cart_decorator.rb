class CartDecorator < Draper::Decorator
  include ActiveSupport::NumberHelper
  delegate_all

  def display_total
    number_to_currency total
  end

  def display_subtotal
    number_to_currency subtotal
  end

  def display_delivery_fees
    return "Free!" if delivery.delivery_schedule.free_delivery?

    number_to_currency delivery_fees
  end
end
