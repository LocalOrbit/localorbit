class CreateMarket
  include Interactor

  def perform
    context[:market] = Market.create(market_params)
    context.fail! if context[:market].errors.any?
  end
end
