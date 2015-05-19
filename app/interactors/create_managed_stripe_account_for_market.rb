class CreateManagedStripeAccountForMarket
  include Interactor

  def perform
    market = context[:market]
    stripe_account = Stripe::Account.create( stripe_account_info(market) )
    market.update(stripe_account_id: stripe_account.id)
    context[:stripe_account] = stripe_account
  end

  def stripe_account_info(market)
    {
      managed:                true,
      # display_name:           market.name, # documented but not accepted?
      business_name:          market.name,
      email:                  market.contact_email,
      country:                'US',
      debit_negative_balances: true,
      metadata: {
        "lo.market_id" => market.id
      }
      # # timezone: :timezone
      # #business_name: :name
    }
  end
end
