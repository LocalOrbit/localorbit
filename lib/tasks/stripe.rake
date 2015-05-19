namespace :stripe do

  namespace :dev do
    desc "Convert Apple Ridge Farm and Judith Coleman over to Stripe in the local dev database"
    task switch_apple_ridge_farm: :environment do
      include StripeDevHelpers
      switch_apple_ridge_farm
    end
  end

  namespace :migrate do
    desc "Download Stripe customer metadata (to local files)"
    task :download_stripe_customer_data do
      ruby "tools/stripe-migration/download_stripe_customer_metadata.rb"
    end

    desc "Download Stripe bank account metadata (to local files)"
    task :download_stripe_bank_accounts do
      secrets = YAML.load_file("../secrets/secrets.yml")
      command = [
        "export STRIPE_SECRET_KEY=#{secrets["production"]["STRIPE_SECRET_KEY"]}",
        "export STRIPE_PUBLISHABLE_KEY=#{secrets["production"]["STRIPE_PUBLISHABLE_KEY"]}",
        "ruby tools/stripe-migration/download_stripe_bank_accounts.rb"
      ].join("; ")
      puts "\n\n"
      puts "HEY YOU: cut n paste this:\n\n"
      puts command
      puts "\n\n"
    end

    desc "Download LO customer metadata (to local files)"
    task :download_lo_customer_data do
      secrets = YAML.load_file("../secrets/secrets.yml")
      command = [
        "export BALANCED_API_KEY=#{secrets["production"]["BALANCED_API_KEY"]}",
        "export BALANCED_MARKETPLACE_URI=#{secrets["production"]["BALANCED_MARKETPLACE_URI"]}",
        "ruby tools/stripe-migration/download_lo_prod_ids.rb"
      ].join("; ")
      puts "\n\n"
      puts "HEY YOU: cut n paste this:\n\n"
      puts command
      puts "\n\n"
      # sh "ruby tools/stripe-migration/download_lo_prod_ids.rb"
    end

    desc "Connect stripe_customer_ids to organizations and markets (local data)"
    task :link_customers do
      ruby "tools/stripe-migration/link_customers.rb"
    end

    desc "Sync stripe_customer_ids from Market files to prod"
    task :push_market_stripe_customer_ids do
      ruby "tools/stripe-migration/push_market_stripe_customer_ids.rb"
    end

    desc "Sync stripe_customer_ids from Organization files to prod"
    task :push_organization_stripe_customer_ids do
      ruby "tools/stripe-migration/push_organization_stripe_customer_ids.rb"
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
