class CreateMarketAddress
  include Interactor
  def perform
    market = context[:market]
    address = MarketAddress.create(billing_params.merge(market_id: market.id, name: market.name, billing: true))
    context[:billing_address] = address
    context.fail! if address.errors.any?
  end

  def rollback
  	context[:billing_address].destroy
  end
end
