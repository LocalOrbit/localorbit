module Admin
  class OrganizationsController < AdminController
    before_action :require_admin_or_market_manager, only: [:new, :create]
    before_action :find_organization, only: [:show, :edit, :update]

    def index
      @organizations = current_user.managed_organizations
    end

    def new
      @organization = Organization.new
      @markets      = current_user.markets
    end

    def create
      result = RegisterOrganization.perform(organization_params: organization_params, user: current_user, market_id: params[:initial_market_id])

      if result.success?
        organization = result.organization
        redirect_to [:admin, organization], notice:"#{organization.name} has been created"
      else
        @markets = current_user.markets
        @organization = result.organization
        render action: :new
      end
    end

    def show
    end

    def update
      if @organization.update_attributes(organization_params)
        redirect_to [:admin, @organization], notice:"Saved #{@organization.name}"
      else
        render action: :show
      end
    end


    private

    def organization_params
      params.require(:organization).permit(
        :name,
        :can_sell,
        :facebook,
        :twitter,
        :who_story,
        :how_story,
        :photo,
        locations_attributes: [:name, :address, :city, :state, :zip, :phone, :fax]
      )
    end

    def find_organization
      @organization = current_user.managed_organizations.find(params[:id])
    end
  end
end
