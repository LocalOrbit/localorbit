require_relative "../../config/environment"

module LinkAccounts
  extend self

  def generate_market_stripe_account_ids_file

    markets = YAML.load_file("tools/stripe-migration/lo-prod-ids/markets.yml")
    data = markets.values.select do |m|
      m[:balanced_customer_meta] and m[:balanced_customer_meta]['stripe.account_id']
    end.map do |m|
      { 
        market_id:          m[:market_id], 
        market_name:        m[:name], 
        stripe_account_id:  m[:balanced_customer_meta]['stripe.account_id'],
        # stripe_customer_id: m[:balanced_customer_meta]['stripe.customer_id'],
      }
    end
    puts "#{data.length} markets have stripe account ids"
    fname = "tools/stripe-migration/market_stripe_account_ids.yml"
    write_yaml fname, data
  end

  def try_to_match_stripe_accounts_to_markets_via_bank_accounts
    sba_data = YAML.load_file('tools/stripe-migration/downloaded_stripe_bank_accounts.yml')
    lo_bank_accounts_hash = YAML.load_file('tools/stripe-migration/lo-prod-ids/bank_accounts.yml')
    lo_bank_accounts_list = lo_bank_accounts_hash.values

    # Step 1: Map stripe accounts 
    #           to their bank accounts 
    #             to their loosely-matching LO bank accounts
    #               to their LO "bankable(s)" (organizations or markets)
    stripe_accounts = {}
    
    sba_data.each do |sba|
      sba = sba.dup
      said = sba[:stripe_account_id]
      bid = sba[:bank_account_id]
      stripe_accounts[said] ||= {}
      stripe_accounts[said][:stripe_account_id] = said
      stripe_accounts[said][:stripe_bank_accounts] ||= {}
      stripe_accounts[said][:stripe_bank_accounts][bid] = sba
    
      lobas = match_bank_accounts(lo_bank_accounts_list, sba)
      loba_infos = lobas.map do |loba|
        {
          lo_bank_account_id: loba[:bank_account_id],
          bankable_desc: "#{loba[:bankable_type]} #{loba[:bankable_id]}"
        }
      end
      sba[:matching_lo_bank_accounts] = loba_infos
    end

    # Step2: Capture the set of unique bankables per Stripe account:
    stripe_accounts.each do |_,sa|
      bankables = sa[:stripe_bank_accounts].values.flat_map do |sba|
        sba[:matching_lo_bank_accounts].map do |x| x[:bankable_desc] end
      end.uniq
      sa[:bankables] = bankables
    end

    # puts YAML.dump(stripe_accounts)


    one_bankable = stripe_accounts.values.select do |sa| sa[:bankables].length == 1 end
    market_bankable = one_bankable.select do |sa| sa[:bankables].first =~ /^Market/ end
    no_bankable = stripe_accounts.values.select do |sa| sa[:bankables].length == 0 end
    multi_bankable = stripe_accounts.values.select do |sa| sa[:bankables].length > 1 end

    puts "Confident matches: #{one_bankable.length}"
    puts "Market matches: #{market_bankable.length}"
    puts "Plural matches: #{multi_bankable.length}"
    puts "Non-matches: #{no_bankable.length}"

    puts 
    puts "Strong matches:"
    puts "market_id\tstripe_account_id"
    market_bankable.each do |sa|
      bankable = sa[:bankables].first
      mname,mid = bankable.split(" ")
      said = sa[:stripe_account_id]
      puts "#{mid}\t#{said}"
    end

    puts
    puts "Multi-matches:"
    puts YAML.dump(multi_bankable)
    puts "market_id(s)\tstripe_account_id"
    multi_bankable.each do |sa|
      ids = sa[:bankables].select do |b|
        b =~ /^Market/
      end.map do |b|
        name,id = b.split(" ")
        id
      end.join(", ")
      said = sa[:stripe_account_id]
      puts "#{ids}\t#{said}"
    end


  end

  def match_bank_accounts(lo_bank_accounts, stripe_bank_account)
    lo_bank_accounts.select do |loba|
      ((loba[:bank_name] == stripe_bank_account[:bank_name]) and (loba[:last_four] == stripe_bank_account[:last4]))
    end
  end

  def write_yaml(fname, data)
    File.write fname, YAML.dump(data)
    puts "Wrote #{fname}"
  end


end


# LinkAccounts.try_to_match_stripe_accounts_to_markets_via_bank_accounts
LinkAccounts.generate_market_stripe_account_ids_file
