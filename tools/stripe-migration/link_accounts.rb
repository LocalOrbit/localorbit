require_relative "../../config/environment"

module LinkAccounts
  extend self

  def go
    bank_accounts = YAML.load_file('tools/stripe-migration/downloaded_stripe_bank_accounts.yml')
    total_count = bank_accounts.length
    match_count = 0
    miss_count = 0
    multi_count = 0

    bank_accounts.each do |sba|
      loba = BankAccount.where(bank_name: sba[:bank_name], last_four: sba[:last4]).to_a
      if loba.length == 0
        puts "!! NO MATCH #{sba.inspect}"
        miss_count += 1

      elsif loba.length == 1
        b = loba.first
        puts "Matched #{sba[:bank_account_id]} => #{b.id} (#{b.bank_name} #{b.last_four})"
        match_count += 1
      else
        puts "MULTI MATCH #{sba[:bank_account_id]}:"
        multi_count += 1
        match_count += 1
        loba.each do |b|
          puts "  Matched #{sba[:bank_account_id]} => #{b.id} (#{b.bank_name} #{b.last_four})"
        end
      end
    end

    puts 
    puts "Stripe bank accounts: #{total_count}"
    puts "Found matches for: #{match_count}"
    puts "  (of those, count of multi-matches): #{multi_count}"
    puts "Unmatched stripe accounts: #{miss_count}"
  end

  def find_matching_in_list(bank_accounts, ba1, ignore:[])
    bank_accounts.select do |ba0|
      (
        (!ignore.include?(ba0[:bank_account_id])) and (ba0[:last4] == ba1[:last4]) and (ba0[:bank_name] == ba1[:bank_name]) and (ba0[:routing_number] == ba1[:routing_number]) 
      )
    end
  end

  def dupes
    bank_accounts = YAML.load_file('tools/stripe-migration/downloaded_stripe_bank_accounts.yml')
    count = 0
    accounted_for = []
    bank_accounts.each do |ba|
      matches = find_matching_in_list(bank_accounts,ba,ignore:accounted_for)
      if matches.length == 1
        # itself?
        if matches.first == ba
          # itself.
          accounted_for << ba[:bank_account_id]
        else
          puts "HUH? 1 match but isn't us: ba=#{ba.inspect} matched:#{matches.first.inspect}"
        end
        
      elsif matches.length == 0
        # puts "WTF? 0 matches for #{ba.inspect}"
      else
        count += 1
        puts "Matched #{ba[:bank_name]} #{ba[:last4]} #{matches.count} times"
        matches.each do |m|
          accounted_for << m[:bank_account_id]
          puts "  #{m.inspect}"
        end
      end
    end
    puts "\nCases of dupes: #{count}"
  end
end


LinkAccounts.dupes
