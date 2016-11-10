class UpdateNextValidDelivery
  include Interactor

  def perform
    if context[:delivery]
      delivery.update_attributes(
        deliver_on: delivery_schedule.next_delivery_date,
        buyer_deliver_on: delivery_schedule.next_buyer_delivery_date,
        cutoff_time: delivery_schedule.next_order_cutoff_time
      )
    end
  end
end
