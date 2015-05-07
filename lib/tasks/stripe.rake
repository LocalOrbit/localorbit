namespace :stripe do

  namespace :dev do
    desc "Convert Apple Ridge Farm and Judith Coleman over to Stripe in the local dev database"
    task switch_apple_ridge_farm: :environment do
      include StripeDevHelpers
      switch_apple_ridge_farm
    end
  end
end



module StripeDevHelpers
  def switch_apple_ridge_farm
    payment_provider = PaymentProvider::Stripe.id

    market_id = 18 # appleridgefarm
    market = Market.find(market_id)
    puts "Market #{market_id}: #{market.name}"
    puts "--> switching to payment provider #{payment_provider}"
    market.update(payment_provider: payment_provider)


    # Stripe account for the market:
    stripe_account = nil
    if market.stripe_account_id.nil?
      puts "No Stripe Account linked to this market?"
      stripe_account = Stripe::Account.all(limit:100).detect { |a| a.email == market.contact_email }
      if stripe_account
        puts "--> Found existing Stripe Account with contact email #{market.contact_email}, using."
      else
        puts "--> Creating new Stripe Account for market #{market.name}, contact email #{market.contact_email}"
        stripe_account = Stripe::Account.create(
          managed: true,
          country: 'US',
          email: market.contact_email
        )
      end
      market.update(stripe_account_id: stripe_account.id)
    end
    puts "Stripe Account for #{market.name}: #{market.stripe_account_id}"
      
    # Stripe Customer for the Buyer:
    buyer_id = 806 # Judith Coleman
    buyer = Organization.find(buyer_id)
    puts "Buyer organization #{buyer_id}: #{buyer.name} (#{buyer.users.first.email})"

    stripe_customer = nil
    if buyer.stripe_customer_id.nil?
      puts "Creating new Stripe Customer for #{buyer.name}"
      stripe_customer = Stripe::Customer.create(
        description: buyer.name,
        metadata: {
          "lo.entity_id" => buyer.id,
          "lo.entity_type" => 'organization'
        }
      )
      buyer.update(stripe_customer_id: stripe_customer.id)
    else
      stripe_customer = Stripe::Customer.retrieve(buyer.stripe_customer_id)
    end
    puts "--> Stripe Customer for #{buyer.name}: #{stripe_customer.id}"

    # Stripe credit card:
    bank_account_id = 121 # Judith's visa ending in 0424
    stripe_card = nil
    visa = buyer.bank_accounts.find(bank_account_id)
    if visa.stripe_id.nil?
      puts "Creating Stripe card"
      token = Stripe::Token.create({
        card:  {
          number: "4012888888881881", 
          exp_month: 5, 
          exp_year: 2016, 
          cvc: "314"
        }
      })

      stripe_card = stripe_customer.sources.create(source: token.id)
      puts "--> Stripe Card #{stripe_card.id} added to Stripe Customer #{stripe_customer.id}"
      visa.update(stripe_id: stripe_card.id)
    else
      puts "--> Card already linked to #{visa.stripe_id}"
    end

    puts "Done."
  end

end
