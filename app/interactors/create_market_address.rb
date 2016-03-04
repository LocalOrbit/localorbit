class CreateMarketAddress
  include Interactor
  def perform
    market = context[:market]
    address = MarketAddress.create(billing_params.merge(market_id: market.id, name: market.name, billing: true))
    context[:billing_address] = address

    unless address.valid? && address.errors.empty?
      context.fail!(error: "Could not create Market address")
    end
  end

  def rollback
    if context_address = context[:billing_address]
      context_address.destroy
    end
  end
end
