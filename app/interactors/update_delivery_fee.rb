class UpdateDeliveryFee
  include Interactor

  def perform
    subtotal = order.items.each.sum(&:gross_total).round(2)
    order.update!(delivery_fees: order.delivery.delivery_schedule.fees_for_amount(subtotal).round(2))
  end
end
