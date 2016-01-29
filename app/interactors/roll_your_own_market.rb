class RollYourOwnMarket
  include Interactor::Organizer

  # KXM Other interactors will be added here, once we have a better idea of what happens at what time
  organize CreateMarket, CreateMarketAddress
end
