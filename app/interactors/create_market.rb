class CreateMarket
  include Interactor

  def perform
    defaults = {
      payment_provider: PaymentProvider.for_new_markets.id,
      stripe_standalone: ENV["USE_STRIPE_STANDALONE_ACCOUNTS"],
    }

    defaults[:plan_fee] = context[:amount] if context[:amount]

    market = Market.create(defaults.merge(market_params).merge({:organization_id => context[:organization][:id]}))
    market.update_attribute(:plan_start_at, Time.current.end_of_minute) if context[:RYO] == true

    context[:market] = market

    unless market.valid? && market.errors.empty?
      context.fail!(error: "Could not create Market")
    end
  end

  def rollback
    if context_market = context[:market]
        context_market.destroy
    end
  end
end
