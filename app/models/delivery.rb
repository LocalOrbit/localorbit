class Delivery < ActiveRecord::Base
  belongs_to :delivery_schedule

  def requires_location?
    !delivery_schedule.buyer_pickup?
  end
end
