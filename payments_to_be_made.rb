# Automate seller payments
# Run this part in a production console
# to produce a report of what is payable
# Email report to Anna

auto_market_ids = Market.joins(:plan).where(plans: {name: "Automate"}).select(:id); nil
orders = Order.payable_to_sellers.where("placed_at > ?", 6.months.ago).where(market_id: auto_market_ids).preload(:items, :organization); nil
groups = SellerPaymentGroup.for_scope(orders).sort_by(&:name); groups.size
groups.each do |group|
  if group.organization.bank_accounts.any?(&:verified)
    name = group.name
  elsif group.organization.bank_accounts.any? {|b| b.account_type == "checking" || b.account_type == "savings" }
    name = "#{group.name} (NOT VERIFIED)"
  else
    name = "#{group.name} (NO BANK ACCOUNT)"
  end
  puts name
  group.orders.each do |order|
    puts "\t#{order.order_number}: $#{"%.2f" % order.items.each.sum {|i| i.seller_net_total }}"
  end
  puts "\tTotal: $#{"%.2f" % group.owed}"
end; nil

# Record automate payments
# After Anna 👍 run this in the same session
# to record the payables above

groups.each do |group|
  bank_account = group.organization.bank_accounts.where(verified: true).first
  next unless bank_account

  orders = Order.find(group.orders.map(&:id))

  puts "Pay #{group.name}: #{group.owed}"

  p = Payment.create(
    orders: orders,
    payee: group.organization,
    payment_type: "seller payment",
    amount: group.owed,
    status: "pending",
    bank_account: bank_account,
    payment_method: "ach",
    market_id: orders.first.market_id
  )
  balanced_account = Balanced::BankAccount.find(bank_account.balanced_uri)
  credit = balanced_account.credit(
    amount: (p.amount * 100).to_i,
    appears_on_statement_as: p.market.name[0, 22]
  )
  p.update_column(:balanced_uri, credit.uri)
end; nil
