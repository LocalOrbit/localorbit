module Sessions
  class DeliverySchedulesController < ApplicationController
    def new
      @deliveries = current_market.delivery_schedules.map { |ds| ds.next_delivery.decorate }
    end

    def create
    end
  end
end
