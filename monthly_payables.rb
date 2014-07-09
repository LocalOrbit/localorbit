# Payable LO fees

orders = Order.payable_lo_fees.where('placed_at > ?', 2.months.ago).preload(:items); nil
grouped = orders.group_by {|o| o.market_id }; grouped.size
lo_fees = Market.where(id: grouped.keys).inject({}) {|h,m| h[m.id] = m.local_orbit_seller_fee > m.local_orbit_market_fee ? m.local_orbit_seller_fee : m.local_orbit_market_fee; h }

grouped.each do |market_id, orders|
  market = Market.find(market_id)
  if market.bank_accounts.any?(&:verified)
    name = market.name
  elsif market.bank_accounts.any? {|b| b.account_type == 'checking' || b.account_type == 'savings' }
    name = "#{market.name} (NOT VERIFIED)"
  else
    name = "#{market.name} (NO BANK ACCOUNT)"
  end
  puts name
  total = BigDecimal.new('0')
  orders.each do |order|
    order_total = order.delivery_fees * lo_fees[market_id] / 100 + order.items.each.sum {|i| i.local_orbit_seller_fee + i.local_orbit_market_fee }
    total += order_total
    puts "\t#{order.order_number}: $#{'%.2f' % order_total}"
  end
  puts "\tTotal: $#{'%.2f' % total}"
end; nil



# Payable Market fees

orders = Order.payable_market_fees.preload(:items, :market); nil
grouped = orders.group_by {|o| o.market_id }; grouped.size
lo_fees = Market.where(id: grouped.keys).inject({}) {|h,m| h[m.id] = m.local_orbit_seller_fee > m.local_orbit_market_fee ? m.local_orbit_seller_fee : m.local_orbit_market_fee; h }

grouped.each do |market_id, orders|
  puts Market.find(market_id).name
  delivery_total = BigDecimal.new('0')
  market_total = BigDecimal.new('0')
  orders.each do |order|
    delivery = order.delivery_fees * (100 - lo_fees[market_id]) / 100
    market = order.items.each.sum {|i| i.market_seller_fee }
    delivery_total += delivery
    market_total += market
    puts "\t#{order.order_number}: Delivery: $#{'%.2f' % delivery}  Market: $#{'%.2f' % market}"
  end
  puts "\tTotal: Delivery: $#{'%.2f' % delivery_total}  Market: $#{'%.2f' % market_total}"
end; nil
