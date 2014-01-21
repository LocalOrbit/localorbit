module Admin
  class OrganizationsController < AdminController
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
      @organization = current_user.managed_organizations.find(params[:id])
    end

    private

    def organization_params
      params.require(:organization).permit(:name, :can_sell)
    end
  end
end
