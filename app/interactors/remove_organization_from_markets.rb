class RemoveOrganizationFromMarkets
  include Interactor

  def perform
    if primary_market_organizations_to_remove.empty?
      fail!(error: "Please choose at least one market to remove #{organization.name} from.")
      return
    end

    context[:message] = "Removed #{organization.name} from #{primary_market_organizations_to_remove.map(&:market).map(&:name).to_sentence}"

    primary_market_organizations_to_remove.soft_delete_all
    cross_sell_market_organizations_to_remove.soft_delete_all
  end

  def primary_market_organizations_to_remove
    organization.market_organizations.not_cross_selling.where(market_id: market_ids)
  end

  def cross_sell_market_organizations_to_remove
    organization.market_organizations.where(cross_sell_origin_market_id: market_ids)
  end
end
