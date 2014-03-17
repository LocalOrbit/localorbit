module Sessions
  class DeliveriesController < ApplicationController
    before_action :require_organization
    before_action :require_organization_location

    def new
      @deliveries = current_market.delivery_schedules.map { |ds| ds.next_delivery.decorate(context: {current_organization: current_organization}) }
    end

    def create
      session[:current_delivery_id] = params[:delivery_id].to_i
      return invalid_delivery_selection if current_delivery.nil?

      if current_delivery.requires_location?
        location_id = params[:location_id][params[:delivery_id]]
        if location = current_organization.locations.find_by(id: location_id)
          session[:current_location] = location.id
        else
          return invalid_delivery_selection
        end
      end

      cart = Cart.find_or_create_by!(organization_id: current_organization.id, market_id: current_market.id, delivery_id: current_delivery.id) do |c|
        c.location_id = location.id if location.present?
      end

      session[:cart_id] = cart.id

      redirect_to :products
    end

    protected

    def invalid_delivery_selection
      flash.now[:alert] = "Please select a delivery"
      self.new
      return render :new
    end

    def require_organization
      redirect_to new_sessions_organization_path unless current_organization
    end

    def require_organization_location
      if current_organization.locations.none?
        redirect_to [:new_admin, current_organization, :location], alert: "You must enter an address for this organization before you can shop"
      end
    end
  end
end
