class Admin::OrganizationCrossSellsController < AdminController
  before_action :find_organization
  before_action :find_cross_selling_markets

  def show
    @cross_sells = @market_cross_sells.all.group_by(&:market)
  end

  def update
    source_to_destination_maps = CoerceSourceToDestinationMaps.call(params[:organization].try(:[], :cross_sell_ids) || {})

    result = UpdateCrossSellingForOrganization.perform(
      organization: @organization,
      source_to_destination_maps: source_to_destination_maps
    )
    if result.success?
      redirect_to admin_organization_cross_sell_path(@organization), notice: "Organization Updated Successfully"
    else
      render :show, error: 'There was a problem updating the cross selling markets'
    end
  end

  protected

  def find_organization
    @organization = current_user.managed_organizations.find_by(id: params[:organization_id])
  end

  def find_cross_selling_markets
    user_allowed_origin_markets = if current_user.organizations.exists?(@organization)
      @organization.markets
    else
      @organization.markets.where(id: Market.managed_by(current_user))
    end
    @market_cross_sells = MarketCrossSells.where(source_market_id: user_allowed_origin_markets).includes(:market)
  end
end
