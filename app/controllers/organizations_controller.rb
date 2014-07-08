class OrganizationsController < ApplicationController
  def index
    @organizations = current_user.organizations.page(params[:page]).per(params[:per_page])
  end
end
