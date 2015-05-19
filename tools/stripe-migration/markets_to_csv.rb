require 'yaml'
require 'csv'

data = YAML.load_file('tools/stripe-migration/lo-prod-ids/markets.yml')

fname = "tools/stripe-migration/lo-prod-ids/markets.csv"
CSV.open(fname,"w") do |csv|
  csv << %w{market_id name stripe_customer_id stripe_account_id balanced_customer_uri balanced_customer_id balanced_underwritten entity_name entity_type entity_id}
  data.each do |_,m|
    meta = m[:balanced_customer_meta] || {}
    csv << [m[:market_id], m[:name], meta['stripe.customer_id'], meta['stripe.account_id'], m[:balanced_customer_uri], m[:balanced_customer_id], m[:balanced_underwritten], meta['entity_name'], meta['entity_type'], meta['entity_id']]
  end
end
puts "Wrote #{fname}"
