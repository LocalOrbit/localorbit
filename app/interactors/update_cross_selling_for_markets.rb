class UpdateCrossSellingForMarkets
  include Interactor

  def perform
    require_in_context(:organization, :source_to_destination_maps)

    Organization.transaction do
      source_to_destination_maps.keys.map do |source_market_id|
        UpdateCrossSellingMarketOrganizations.perform(
          organization: organization,
          source_market_id: source_market_id,
          destination_market_ids: source_to_destination_maps[source_market_id] || []
        )
      end
    end
  end

end
