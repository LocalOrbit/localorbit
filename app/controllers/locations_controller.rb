class LocationsController < ApplicationController
  before_action :find_organization

  def index
    render json: @organization.locations
  end

  private

  def find_organization
    @organization = current_user.managed_organizations.find(params[:organization_id])
  end
end
