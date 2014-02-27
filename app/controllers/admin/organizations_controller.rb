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
      if params[:initial_market_id].blank?
        @organization = Organization.new(organization_params)
        @organization.errors.add(:markets, :blank)
      else
        @market = current_user.markets.find(params[:initial_market_id])
        @organization =  @market.organizations.create(organization_params)
      end

      if @organization.errors.none?
        redirect_to [:admin, @organization], notice:"#{@organization.name} has been created"
      else
        @markets = current_user.markets
        render action: :new
      end
    end

    def show
    end

    def edit
    end

    def update
      if @organization.update_attributes(organization_params)
        redirect_to [:admin, @organization], notice:"Saved #{@organization.name}"
      else
        render action: :edit
      end
    end


    private

    def organization_params
      params.require(:organization).permit(
        :name,
        :can_sell,
        :who_story,
        :how_story,
        locations_attributes: [:name, :address, :city, :state, :zip]
      )
    end

    def find_organization
      @organization = current_user.managed_organizations.find(params[:id])
    end
  end
end
