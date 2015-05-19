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
end


LinkAccounts.go
