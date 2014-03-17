module Sessions
  class OrganizationsController < ApplicationController
    def new
      @organizations = current_user.managed_organizations.joins(:market_organizations).where('market_organizations.market_id' => current_market.id)
    end

    def create
      if org = current_user.managed_organizations.find_by(id: params[:org_id])
        session[:current_organization_id] = org.id
        redirect_to [:products]
      else
        flash[:alert] = "Please select an organization"
        self.new
        render :new
      end
    end
  end
end
