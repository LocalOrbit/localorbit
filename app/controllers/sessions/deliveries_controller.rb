module Sessions
  class DeliveriesController < ApplicationController
    def new
      @deliveries = current_market.delivery_schedules.map { |ds| ds.next_delivery.decorate(context: {current_organization: current_organization}) }
    end

    def create
      unless params[:delivery] && params[:delivery][:id].present?
        flash[:alert] = "Please select a delivery"
        return render :new
      end

      if params[:location] && params[:location][:id]
        location = current_organization.locations.find_by(id: params[:location][:id].to_i)

        if location
          session[:current_location] = location.id
        else
          return redirect_to [:sessions, :deliveries], alert: "Please select a different location"
        end
      else
        session[:current_location] = current_organization.locations.first.id
      end

      session[:current_delivery] = params[:delivery][:id].to_i
      redirect_to :products
    end
  end
end
