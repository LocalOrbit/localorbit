module Sessions
  class OrganizationsController < ApplicationController
    def new
      @organizations = current_user.managed_organizations
    end

    def create
      unless params[:organization] && params[:organization][:id].present?
        flash[:alert] = "Please select an organization"
        return render :new
      end

      org = current_user.managed_organizations.find_by(id: params[:organization][:id])

      unless org.present?
        flash[:alert] = "Please select a different organization"
        return render :new
      end

      session[:current_organization_id] = org.id
      redirect_to [:products]
    end
  end
end
