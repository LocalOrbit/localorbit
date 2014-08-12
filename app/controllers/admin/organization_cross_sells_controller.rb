class Admin::OrganizationCrossSellsController < AdminController
  before_action :find_organization
  before_action :find_cross_selling_markets

  def show
    @cross_sells = @cross_selling_markets.all.group_by(&:market)
  end

  def update
    cross_sells = params[:organization].try(:[], :cross_sell_ids) || {}

    @cross_selling_markets.each do |csm|
      source_id = csm.source_market_id
      @organization.update_cross_sells!(from_market: Market.find(source_id), to_ids: cross_sells[source_id.to_s] || [])
    end

    redirect_to admin_organization_cross_sell_path(@organization), notice: "Organization Updated Successfully"
  end

  protected

  def find_organization
    @organization = current_user.managed_organizations.find(params[:organization_id])
  end

  def find_cross_selling_markets
    user_allowed_origin_markets = if current_user.organizations.exists?(@organization)
      @organization.markets
    else
      user_managed_markets = current_user.admin? ? Market.all : current_user.managed_markets
      @organization.markets.where(id: user_managed_markets.pluck(:id))
    end
    @cross_selling_markets = MarketCrossSells.where(source_market_id: user_allowed_origin_markets)
  end
end
