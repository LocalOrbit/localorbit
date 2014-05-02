class Admin::OrganizationCrossSellsController < AdminController
  before_filter :find_organization

  def show
    @cross_selling_markets = @organization.markets.map {|m| m.cross_sells }.flatten.uniq
  end

  def update
    ids = params[:organization].try(:[], :cross_sell_ids) || []

    @organization.cross_sell_ids = ids
    @organization.market_organizations.where(market_id: ids).update_all(cross_sell: true)

    redirect_to admin_organization_cross_sell_path(@organization), notice: "Organization Updated Successfully"
  end

  protected

  def find_organization
    @organization = current_user.managed_organizations.find(params[:organization_id])
  end
end
