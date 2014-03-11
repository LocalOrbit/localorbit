module Sessions
  class DeliveriesController < ApplicationController
    def new
      @deliveries = current_market.delivery_schedules.map { |ds| ds.next_delivery.decorate(context: {current_organization: current_organization}) }
    end

    def create
      session[:current_delivery] = params[:delivery][:id]
      redirect_to :products
    end
  end
end
