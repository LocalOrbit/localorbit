module Sessions
  class DeliverySchedulesController < ApplicationController
    def new
      @deliveries = current_market.delivery_schedules.map { |ds| ds.next_delivery }
    end

    def create
    end
  end
end
