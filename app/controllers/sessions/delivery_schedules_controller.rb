module Sessions
  class DeliverySchedulesController < ApplicationController
    def new
      @delivery_schedules = current_organization.market.delivery_schedules.map { |ds| ds.next_delivery }
    end

    def create
    end
  end
end
