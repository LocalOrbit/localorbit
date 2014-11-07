# Payable LO fees

orders = Order.payable_lo_fees.clean_payment_records.preload(:items, :market).joins(:market).order("MAX(markets.name)", "orders.order_number")
grouped = orders.group_by {|o| o.market_id }; grouped.size
lo_fees = Market.where(id: grouped.keys).inject({}) {|h,m| h[m.id] = m.local_orbit_seller_fee > m.local_orbit_market_fee ? m.local_orbit_seller_fee : m.local_orbit_market_fee; h }

grouped.each do |market_id, orders|
  market = Market.find(market_id)
  next if market.demo?
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
    puts "\t#{order.order_number}: $#{'%.2f' % order_total}" if order_total > 0
  end
  puts "\tTotal: $#{'%.2f' % total}"
end; nil

# Process above payments
grouped.each do |market_id, orders|
  market = Market.find(market_id)
  next if market.demo?

  amount = orders.each.sum do |order|
    order.delivery_fees * lo_fees[market_id] / 100 + order.items.each.sum {|i| i.local_orbit_seller_fee + i.local_orbit_market_fee }
  end
  if amount <= 10
    puts "Total below $10 for #{market.name}"
    next
  end

  if market.bank_accounts.where(verified: true).size != 1
    puts "Could not select a bank account for #{market.name}"
    next
  end
  bank_account = market.bank_accounts.where(verified: true).first
  payment = Payment.create(
    market_id: market_id,
    payment_type: "lo fee",
    amount: amount,
    status: "pending",
    payer: market,
    payment_method: "ach",
    bank_account_id: bank_account.id,
    orders: orders
  )

  interactor = ProcessPaymentWithBalanced.perform(payment: payment, description: "Local Orbit transaction fees")
  if interactor.success?
    puts "Charged #{market.name} $#{"%0.2f" % amount}"
  else
    puts interactor.error.inspect
  end
end; nil



#############################################################################
# 
# Monthly payments to 'Automate' Markets
#
#############################################################################

# Step 1: Copy-n-paste the code below into a heroku terminal, then copy-n-paste the output
#         in an email to Anna or Dawn @ LocalOrbit

orders = Order.payable_market_fees.preload(:items, :market).joins(:market).except(:order).order("MAX(markets.name)", "orders.order_number"); nil
grouped = orders.group_by {|o| o.market_id }; grouped.size
lo_fees = Market.where(id: grouped.keys).inject({}) {|h,m| h[m.id] = m.local_orbit_seller_fee > m.local_orbit_market_fee ? m.local_orbit_seller_fee : m.local_orbit_market_fee; h }

grouped.each do |market_id, orders|
  market = Market.find(market_id)
  next if market.demo?
  puts market.name
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

# Step 2: When approved by Anna or Dawn, copy-n-paste the rest of this code in the 
#         Heroku terminal to actually execute the payments.  Copy the output back via
#         email to Anna or Dawn for posterity.

grouped.each do |market_id, orders|
  market = Market.find(market_id)
  next if market.demo?

  if market.bank_accounts.where(verified: true).size != 1
    puts "Could not select a bank account for #{market.name}"
    next
  end

  amount = orders.sum {|order| order.delivery_fees * (100 - lo_fees[market_id]) / 100 }
  if amount > 0
    payment = Payment.create(
      market: market,
      payee:  market,
      payment_type: "delivery fee",
      amount: amount,
      status: "pending",
      payment_method: "ach",
      bank_account: market.bank_accounts.where(verified: true).first,
      orders: orders
    )

    interactor = ProcessPaymentWithBalanced.perform(payment: payment, description: "Local Orbit delivery fees")
    if interactor.success?
      puts "Paid delivery fee to %s of $%.2f" % [market.name, amount]
    else
      puts interactor.error.inspect
    end
  else
    puts "No payable delivery fees for #{market.name}"
  end

  amount = orders.sum {|order| order.items.each.sum {|i| i.market_seller_fee } }
  if amount > 0
    payment = Payment.create(
      market: market,
      payee:  market,
      payment_type: "hub fee",
      amount: amount,
      status: "pending",
      payment_method: "ach",
      bank_account: market.bank_accounts.where(verified: true).first,
      orders: orders
    )

    interactor = ProcessPaymentWithBalanced.perform(payment: payment, description: "Local Orbit market fees")
    if interactor.success?
      puts "Paid market fee to %s of $%.2f" % [market.name, amount]
    else
      puts interactor.error.inspect
    end
  else
    puts "No payable market fees for #{market.name}"
  end
end; nil
