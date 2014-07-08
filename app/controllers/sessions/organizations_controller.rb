module Sessions
  class OrganizationsController < ApplicationController
    before_action :hide_admin_navigation

    def new
      @organizations = current_user.managed_organizations_within_market(current_market).order(:name)
    end

    def create
      if (org = current_user.managed_organizations.find_by(id: params[:org_id]))
        session[:current_organization_id] = org.id
        redirect_to redirect_to_url
      else
        flash[:alert] = "Please select an organization"
        new
        render :new
      end
    end
  end
end
