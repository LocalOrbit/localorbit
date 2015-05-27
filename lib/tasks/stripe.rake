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

    # desc "Sync stripe_customer_ids from Market files to prod"
    # task :push_market_stripe_customer_ids do
    #   ruby "tools/stripe-migration/push_market_stripe_customer_ids.rb"
    # end
    #
    # desc "Sync stripe_account_ids from Market files to prod"
    # task :push_market_stripe_customer_ids do
    #   ruby "tools/stripe-migration/push_market_stripe_account_ids.rb"
    # end
    #
    # desc "Sync stripe_customer_ids from Organization files to prod"
    # task :push_organization_stripe_customer_ids do
    #   ruby "tools/stripe-migration/push_organization_stripe_customer_ids.rb"
    # end

    # desc "For all BankAccounts, try to connect them to their Stripe IDs"
    # task :update_market_bank_account_stripe_ids do
    #   secrets = YAML.load_file("../secrets/secrets.yml")
    #   command = [
    #     "export STRIPE_SECRET_KEY=#{secrets["production"]["STRIPE_SECRET_KEY"]}",
    #     "export STRIPE_PUBLISHABLE_KEY=#{secrets["production"]["STRIPE_PUBLISHABLE_KEY"]}",
    #     "ruby tools/stripe-migration/update_market_bank_account_stripe_ids.rb"
    #   ].join("; ")
    #   puts "\n\n"
    #   puts "HEY YOU: cut n paste this:\n\n"
    #   puts command
    #   puts "\n\n"
    # end

    desc "Update stripe*_ids for orgs and bank accounts in a given Market" 
    task :update_stripe_ids_on_market do
      env = { 'RAILS_ENV' => 'production' }
      market_id = ENV['market_id'] || ENV['market'] || raise("Set market id, eg, market=18")
      command = "ruby tools/stripe-migration/update_stripe_ids_on_market.rb #{market_id}"
      puts command
      exec(env, command)
    end

    desc "Update stripe*_ids across all active markets"
    task :update_stripe_ids_on_active_markets do
      active_market_ids = "39,36,18,15,13,19,8,68,38,57,58,60,27,65,17,45,9,32,62,61,20,88,2,67,12,4,82,7,91,63,11,77,86,46,54,70,92,43"
      ENV['market'] = active_market_ids
      Rake::Task["stripe:migrate:update_stripe_ids_on_market"].invoke
    end

    desc "Set transfer schedule and debit_negative_balances flag"
    task :set_transfer_schedule do
      env = { 'RAILS_ENV' => 'production' }
      market_id = ENV['market_id'] || ENV['market'] || raise("Set market id, eg, market=18")
      command = "ruby tools/stripe-migration/set_transfer_schedule.rb #{market_id}"
      puts command
      exec(env, command)
    end

    desc "Update transfer_schedule and debit_negative_balance flag across all active markets"
    task :set_transfer_schedules_on_active_markets do
      # active_market_ids = "39,36,18,15,13,19,8,68,38,57,58,60,27,65,17,45,9,32,62,61,20,88,2,67,12,4,82,7,91,63,11,77,86,46,54,70,92,43"
      active_market_ids = "'18, 4, 17, 45, 70, 38, 36, 2, 67, 7, 19, 65, 61, 9, 82'"
      ENV['market'] = active_market_ids
      Rake::Task["stripe:migrate:set_transfer_schedule"].invoke
    end

    desc "Flip market to stripe"
    task :flip_market_to_stripe do
      env = { 'RAILS_ENV' => 'production' }
      market_id = ENV['market_id'] || ENV['market'] || raise("Set market id, eg, market=18")
      command = "ruby tools/stripe-migration/flip_market_to_stripe.rb #{market_id}"
      puts command
      exec(env, command)
    end
  end
end

