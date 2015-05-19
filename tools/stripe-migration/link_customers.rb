module LinkCustomers
  def link_market_customers(market)

  end
end

market_id = ARGV.shift
market = Market.find(market_id)
LinkCustomers.link_market_customers(market)
