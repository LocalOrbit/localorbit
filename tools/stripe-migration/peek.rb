require_relative('../../config/environment')
require_relative('balanced_export')

module Peekaboo
  extend self
  def go
    export = BalancedExport.latest
    rows = export.data.select do |row|
      row['funding_instrument_guid'] != nil
    end
    puts "Processing #{rows.count} rows..."; $stdout.flush
    rows.each do |row|
      baid = row['funding_instrument_guid']
      if ba = BankAccount.where("balanced_uri LIKE '%/#{baid}'").first
      else
        puts baid
      end
        
    end
    
  end

  def peek1
    markets = YAML.load_file('tools/stripe-migration/market_stripe_account_ids.yml')

    export = BalancedExport.new
    # data = get_export_data
    #
    # said = markets.first[:stripe_account_id]
    # hits = search_rows(data, 'stripe.account_id', said)
    # binding.pry
    # exit

    markets.each do |m|
      said = m[:stripe_account_id]
      rows = export.search('stripe.account_id', said)
      if rows.length == 0
        puts "!! NO FIND stripe.account_id == #{said}"
      else
        puts "For stripe.account_id == #{said}:"
        rows.each do |hit|
          puts "  #{hit.inspect}"
        end
      end
    end
  end
end

puts "Rails env #{Rails.env}"
Peekaboo.go
