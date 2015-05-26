require_relative "../../config/environment"

puts "Rails.env: #{Rails.env}"
puts "ActiveRecord::Base.connection.current_database: #{ActiveRecord::Base.connection.current_database}"

green_market_ids = [70, 38, 36, 2, 67, 7, 19, 65, 61, 9 ]
red_market_ids = [ 18, 4, 17, 45, 82 ]

def review_markets(mids)
  mids.each do |mid|
    m = Market.find(mid)
    puts "#{m.name} (#{mid})"
    [ :stripe_customer_id, :stripe_account_id, :balanced_customer_uri ].each do |f|
      puts "  #{f}: #{m[f]}"
    end
    puts "  Bank accounts:"
    m.bank_accounts.each do |ba|
      puts "    #{ba.name} #{ba.last_four} (#{ba.id}) balanced_uri: #{ba.balanced_uri}, stripe_id: #{ba.stripe_id}"
    end
    puts
    puts
  end
end

puts "GREEN MARKETS:"
review_markets(green_market_ids)

puts
puts "RED MARKETS:"
review_markets(red_market_ids)

