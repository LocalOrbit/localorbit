class RemoveOrganizationFromMarkets
  include Interactor

  def perform
    if market_ids.blank?
      fail!(error: "Please choose at least one market to remove #{organization.name} from.")
      return
    end

    removed_from = {
      markets: organization.market_organizations.not_cross_selling.where(market_id: market_ids),
      cross_sells: organization.market_organizations.where(cross_sell_origin_market_id: market_ids)
    }

    # Guards against case where admin remove reported incorrect removal from market
    if removed_from[:markets].empty?
      fail!(error: "Please choose at least one market to remove #{organization.name} from.")
      return
    end

    postfix = if (removed_from[:markets].size > 1)
      "market membership(s)"
    else
      removed_from[:markets].first.market.name
    end

    context[:message] = "Removed #{organization.name} from #{postfix}"

    removed_from[:markets].soft_delete_all
    removed_from[:cross_sells].soft_delete_all
  end
end
