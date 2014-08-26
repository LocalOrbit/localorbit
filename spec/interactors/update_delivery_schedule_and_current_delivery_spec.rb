require "spec_helper"

describe UpdateDeliveryScheduleAndCurrentDelivery do
  let(:delivery_schedule) { create(:delivery_schedule, order_cutoff: 120) }
  let(:delivery_schedule_params) { {order_cutoff: 240} }

  let(:interactor) do
    UpdateDeliveryScheduleAndCurrentDelivery.new(
    delivery_schedule: delivery_schedule,
    params: delivery_schedule_params
  )
  end

  before do
    Timecop.freeze(Date.parse("2013-09-01"))
  end

  after do
    Timecop.return
  end

  describe "#perform" do
    it "edits the delivery schedule" do
      expect {
        interactor.perform
      }.to change {
        delivery_schedule.order_cutoff
      }.from(120).to(240)
    end

    it "edits any future valid delivery that exists" do
      delivery = delivery_schedule.deliveries.create({
        cutoff_time: DateTime.parse("2013-09-05 11:00:00"),
        deliver_on: DateTime.parse("2013-09-10 11:00:00")
      })

      expect {
        interactor.perform
      }.to change {
        delivery.reload.cutoff_time
      }.to(DateTime.parse("2013-08-31 11:00:00"))
    end

    it "does not edit any valid deliveries that exist" do
      delivery = delivery_schedule.deliveries.create({
        deliver_on: DateTime.parse("2013-09-03 11:00:00"),
        cutoff_time: DateTime.parse("2013-08-27 11:00:00")
      })

      expect {
        interactor.perform
      }.not_to change {
        delivery
      }
    end
  end
end
