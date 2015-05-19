require 'csv'
require 'yaml'

def index(rows)
  h = {}
  rows.each do |r|
    h[r['customer_guid']] = r
  end
  h
end

export_file = Dir["tools/stripe-migration/from_balanced/*.csv"].sort.last
export_data = CSV.read(export_file, headers: true)

by_cid = index(export_data)

markets = YAML.load_file("tools/stripe-migration/lo-prod-ids/markets.yml")
markets.values.select do |m|
  m[:balanced_customer_id] != nil
end.each do |m|
  row = by_cid[m[:balanced_customer_id]]
  if row['stripe.account_id']
    puts "#{m[:market_id]}\t#{row['stripe.account_id']}"
  end
end

