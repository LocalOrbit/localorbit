module Sessions
  class OrganizationsController < ApplicationController
    def new
      @organizations = current_user.managed_organizations
    end

    def create
      session[:current_organization_id] = params[:org_id]
      redirect_to [:products]
    end
  end
end
