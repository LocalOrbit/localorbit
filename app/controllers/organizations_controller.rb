class OrganizationsController < ApplicationController
  def index
    @organizations = current_user.organizations_including_suspended.page(params[:page]).per(params[:per_page])
  end
end
