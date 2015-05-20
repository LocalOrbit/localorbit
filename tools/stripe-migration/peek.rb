require 'yaml'
require 'csv'
require 'pry'
require_relative('balanced_export')

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

