class UpdateDeliveryScheduleAndCurrentDelivery
  include Interactor::Organizer

  organize [
    UpdateDeliverySchedule,
    UpdateNextValidDelivery
  ]
end
