module Generate
  extend self

  def market_with_orders(opts={})
    num_orders = opts[:num_orders] || 2
    num_sellers = opts[:num_sellers] || num_orders
    num_products = opts[:num_products] || num_sellers
    order_time = opts[:order_time]
    deliver_time = opts[:deliver_time]
    paid_with = opts[:paid_with]
    delivered = opts[:delivered]
    num_order_items = opts[:items] || 1

    #
    # Market
    #
    plan = FactoryGirl.create(:plan, :automate)
    market = FactoryGirl.create(:market, plan: plan)

    #
    # Buyers
    #
    n = num_orders
    buyer_users = []
    buyer_orgs = []
    n.times do |i|
      user = FactoryGirl.create(:user)
      buyer_users << user
      org = FactoryGirl.create(:organization, :buyer, users: [user], markets: [market])
      buyer_orgs << org
    end

    #
    # Sellers
    #
    n = num_sellers
    seller_users = []
    seller_orgs = []
    n.times do |i|
      user = FactoryGirl.create(:user)
      seller_users << user
      org = FactoryGirl.create(:organization, :seller, 
                               users: [user], 
                               markets: [market],
                               bank_accounts: [
                                 FactoryGirl.create(:bank_account, :credit_card),
                                 FactoryGirl.create(:bank_account, :savings, bank_name: "West Bank"),
                                 FactoryGirl.create(:bank_account, :savings, :verified, bank_name: "East Bank"),
                                 FactoryGirl.create(:bank_account, :checking, :verified, bank_name: "North Bank"),
                              ])
      seller_orgs << org
    end

    #
    # Products 
    #
    products = []
    n = num_products
    sorgs = seller_orgs.cycle
    n.times do |i|
      seller_org = sorgs.next
      product = FactoryGirl.create(:product, :sellable, organization: seller_org)
      # TODO SET PRICE OF PRODUCT?
      # price = (i.to_f + (i.to_f/10)).to_d
      products << product
    end

    #
    # Orders
    #
    orders = []
    borgs = buyer_orgs.cycle
    prods = products.cycle
    num_orders.times do |i|
      buyer_org = borgs.next
      order_items = []

      num_order_items.times do |i|
        product = prods.next
        quant = i+1
        price = (quant.to_f + (quant.to_f/10)).to_d # TODO: somehow derive from Product?
        order_item = FactoryGirl.create(:order_item, 
                                        product: product, 
                                        quantity: quant, 
                                        unit_price: price.to_d,
                                        market_seller_fee:      0.1.to_d,
                                        local_orbit_seller_fee: 0.2.to_d,
                                        payment_seller_fee:     0.3.to_d,
                                        discount_seller:        0.4.to_d)
        if order_time
          order_item.update_column(:created_at, order_time)
          order_item.update_column(:updated_at, order_time)
        end
        if delivered
          order_item.update(delivery_status: delivered)
        end
        order_items << order_item
      end

      order = FactoryGirl.create(:order, items: order_items, organization: buyer_org, market: market)
      if order_time
        order.update_column(:created_at, order_time)
        order.update_column(:updated_at, order_time)
        order.update_column(:placed_at, order_time)
      end
      if deliver_time
        order.delivery.update(deliver_on: deliver_time, buyer_deliver_on: deliver_time)
      end
      if paid_with
        order.update(payment_status: "paid", payment_method: paid_with)
      end
      orders << order
    end

    return {
      market: market,
      buyer_users: buyer_users,
      buyer_organizations: buyer_orgs,
      seller_users: seller_users,
      seller_organizations: seller_orgs,
      products: products,
      orders: orders
    }
  end


end
