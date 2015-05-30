class CreateManagedStripeAccountForMarket
  include Interactor

  def perform
    market = context[:market]
    stripe_account = market.stripe_account
    if stripe_account.nil?
      stripe_account = Stripe::Account.create( stripe_account_info(market) )
      market.update(stripe_account_id: stripe_account.id)
    end
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
      transfer_schedule: PaymentProvider::Stripe::TransferSchedule.stringify_keys,
      metadata: {
        "lo.market_id" => market.id
      }
      # # timezone: :timezone
      # #business_name: :name
    }
  end
end
