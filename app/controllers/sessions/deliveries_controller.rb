module Sessions
  class DeliveriesController < ApplicationController
    def new
      @deliveries = current_market.delivery_schedules.map { |ds| ds.next_delivery.decorate(context: {current_organization: current_organization}) }
    end

    def create
      if id = params[:delivery].try(:[], :id).presence
        session[:current_delivery_id] = id.to_i
      else
        flash.now[:alert] = "Please select a delivery"
        return render :new
      end

      if current_organization.locations.size > 1
        if location = current_organization.locations.find_by(id: params[:location].try(:[], :id).to_i)
          session[:current_location] = location.id
        else
          return redirect_to [:sessions, :deliveries], alert: "Please select a location"
        end
      else
        session[:current_location] = current_organization.locations.first.id
      end

      redirect_to :products
    end
  end
end
