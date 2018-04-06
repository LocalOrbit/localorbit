class UpdateCrossSellingMarketOrganizations
  include Interactor

  def perform
    require_in_context(:organization, :source_market_id, :destination_market_ids)

    original_cross_sells = organization.market_organizations.visible.
      where(cross_sell_origin_market_id: source_market_id)
    cross_sells_to_remove = original_cross_sells.where.not(market_id: destination_market_ids)
    new_cross_sell_ids = destination_market_ids - original_cross_sells.pluck(:market_id)

    # create the new ones
    new_cross_sell_ids.each do |new_cross_sell_id|
      organization.market_organizations.create(market_id: new_cross_sell_id, cross_sell_origin_market_id: source_market_id)
    end

    # destroy the old ones
    cross_sells_to_remove.soft_delete_all
  end

end
