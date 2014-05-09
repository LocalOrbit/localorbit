class UpdateDeliverySchedule
  include Interactor

  def setup
    context[:delivery] = delivery_schedule.find_next_delivery
  end

  def perform
    delivery_schedule.update(params) || context.fail!
  end
end
