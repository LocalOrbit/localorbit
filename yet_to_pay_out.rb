# Automate Market fees
automate_market_ids = Market.joins(:plan).where(plans: {name: "Automate"}).select(:id)
automate_market = Order.used_lo_payment_processing.paid.
  not_paid_for("hub fee").
  where("orders.placed_at > ?", Time.parse("2014-01-01")).
  where(market_id: automate_market_ids).
  joins(:items).
  sum("order_items.market_seller_fee")


# Automate Sellers
subselect = "SELECT 1 FROM payments
      INNER JOIN order_payments ON order_payments.order_id = orders.id AND order_payments.payment_id = payments.id
      WHERE payments.payee_type = ? AND payments.payee_id = products.organization_id"
automate_seller = Order.used_lo_payment_processing.paid.
  where("NOT EXISTS(#{subselect})", "Organization").
  joins(items: :product).
  where("orders.placed_at > ?", Time.parse("2014-01-01")).
  where(market_id: automate_market_ids).
  sum("unit_price * COALESCE(quantity_delivered, quantity) - market_seller_fee - local_orbit_seller_fee - payment_seller_fee - discount_seller")


# Normal market payment
non_automate_market_ids = Market.joins(:plan).where.not(plans: {name: "Automate"}).select(:id)

items_owed_market = Order.paid.used_lo_payment_processing.not_paid_for("market payment").
  where("orders.placed_at > ?", Time.parse("2014-01-01")).
  where(market_id: non_automate_market_ids).
  joins(:items).
  sum("unit_price * COALESCE(quantity_delivered, quantity) - local_orbit_market_fee - local_orbit_seller_fee - payment_seller_fee - payment_market_fee - discount_market")

# This does not account for withholding LO fees
delivery_owed_market = Order.paid.used_lo_payment_processing.not_paid_for("market payment").
  where("orders.placed_at > ?", Time.parse("2014-01-01")).
  where(market_id: non_automate_market_ids).
  sum(:delivery_fees)

# Total yet to pay out
total = automate_market + automate_seller + items_owed_market + delivery_owed_market

# Not yet reflected in the balanced escrow
pending = Payment.where(status: "pending", payee_id: nil).where.not(balanced_uri: nil).sum(:amount)

# Rough estimate for safe to withdrawl
BigDecimal.new(Balanced::Marketplace.my_marketplace.in_escrow) / 100 + pending - total
