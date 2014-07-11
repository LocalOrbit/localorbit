class RemoveOrganizationFromMarkets
  include Interactor

  def perform
    if market_ids.blank?
      fail!(error: "Please choose at least one market to remove #{organization.name} from.")
      return
    end

    organization.market_organizations.not_cross_selling.where(market_id: market_ids).soft_delete_all
    organization.market_organizations.where(cross_sell_origin_market_id: market_ids).soft_delete_all
  end
end