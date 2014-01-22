module Admin
  class OrganizationsController < AdminController
    before_action :require_admin_or_market_manager
    before_action :find_organization, only: [:show, :edit, :update]

    def index
      @organizations = current_user.managed_organizations
    end

    def new
      @organization = Organization.new
      @markets      = current_user.markets
    end

    def create
      @market = current_user.markets.find(params[:organization][:market])
      @organization =  @market.organizations.create(organization_params)
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
      params.require(:organization).permit(:name, :can_sell)
    end

    def find_organization
      @organization = current_user.managed_organizations.find(params[:id])
    end
  end
end
