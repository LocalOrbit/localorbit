module Admin
  class LocationsController < AdminController
    before_action :find_organization

    def index
      @locations = @organization.locations.decorate
    end

    def new
      @location = @organization.locations.build
    end

    def create
      @location = @organization.locations.build(location_params)

      if @location.save
        redirect_to [:admin, @organization, :locations], notice: "Successfully added address #{@location.name}"
      else
        flash.now[:alert] = "Could not save address"
        render :new
      end
    end

    def destroy
      @locations = @organization.locations.destroy(*params[:location_ids])
      redirect_to [:admin, @organization, :locations], notice: "Successfully removed the address(es) #{location_names}"
    end

    private

    def find_organization
      @organization = current_user.managed_organizations.find(params[:organization_id])
    end

    def location_params
      params.require(:location).permit(:name, :address, :city, :state, :zip, :default_billing)
    end

    def location_names
      @locations.map(&:name).to_sentence
    end
  end
end
