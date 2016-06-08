shared_context "the mini market" do
  let!(:mini_market_plan) {create(:plan, :grow) }
  let!(:mini_market_org) { create(:organization, :market, plan: mini_market_plan)}
  let!(:mini_market) { create(:market, name: "Mini Market", organization: mini_market_org) }
  let!(:mary) { create(:user, :market_manager, name: "Mary", managed_markets: [mini_market]) }
  let!(:mary) { create(:user, :market_manager, name: "Mary", managed_markets: [mini_market], email: "mary+testing@example.com") }

  let!(:sally) { create(:user, :supplier, name: "Sally") }
  let!(:seller_organization) { create(:organization, :seller, name: "Sally's Staples", users: [sally], markets:[mini_market]) }

  let!(:barry) { create(:user, :buyer, name: "Barry Sagitarius") }
  let!(:buyer_organization) { create(:organization, :buyer, name: barry.name, users: [barry], markets:[mini_market]) }

  let!(:aaron) { create(:user, :admin, name: "Aaron") }

  let!(:sally_product1) { create(:product, :sellable, organization: seller_organization) }
  let!(:sally_product2) { create(:product, :sellable, organization: seller_organization) }

  let!(:order1_item1) { create(:order_item, product: sally_product1) }
  let!(:order1) { create(:order, items: [order1_item1], market: mini_market, organization: buyer_organization) }

  let!(:order2_item1) { create(:order_item, product: sally_product2) }
  let!(:order2) { create(:order, items: [order2_item1], market: mini_market, organization: buyer_organization) }

  let!(:mm_product1)           { create(:product, :sellable, organization: seller_organization) }
  let!(:mm_order1_item1)       { create(:order_item, product: mm_product1, quantity: 2, unit_price: 3.00) }
  let(:mm_order1_items) { [mm_order1_item1] }
  let!(:mm_order) { create(:order, items: mm_order1_items, organization: buyer_organization, market: mini_market) } # HUH?

  let!(:mm_order1) { create(:order, items: mm_order1_items, organization: buyer_organization, market: mini_market) }
  let(:mm_order) { mm_order1 } # HUH?
  let(:mm_order1_items) { [mm_order1_item1] }
  let!(:mm_product1)           { create(:product, :sellable, organization: seller_organization) }
  let!(:mm_order1_item1)       { create(:order_item, product: mm_product1, quantity: 2, unit_price: 3.00) }

  let!(:mm_delivery_schedule) { create(:delivery_schedule, market: mini_market) }

end
