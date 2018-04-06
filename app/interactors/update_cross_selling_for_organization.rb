class UpdateCrossSellingForOrganization
  include Interactor::Organizer

  organize UpdateCrossSellingForMarkets, UpdateDeliverySchedulesForProducts
end
