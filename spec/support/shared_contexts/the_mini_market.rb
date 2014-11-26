shared_context "the mini market" do
  let!(:mini_market) { create(:market, name: "Mini Market") }
  let!(:mary) { create(:user, :market_manager, name: "Mary", managed_markets: [mini_market], email: "mary+testing@example.com") }

  let!(:sally) { create(:user, name: "Sally") }
  let!(:seller_organization) { create(:organization, :seller, name: "Sally's Staples", users: [sally], markets:[mini_market]) }

  let!(:barry) { create(:user, name: "Barry") }
  let!(:buyer_organization) { create(:organization, :buyer, users: [barry], markets:[mini_market]) }

  let!(:aaron) { create(:user, :admin, name: "Aaron") }


  let!(:sally_product1) { create(:product, :sellable, organization: seller_organization) }
  let!(:sally_product2) { create(:product, :sellable, organization: seller_organization) }

  let!(:order1_item1) { create(:order_item, product: sally_product1) }
  let!(:order1) { create(:order, items: [order1_item1], market: mini_market, organization: buyer_organization) }

  let!(:order2_item1) { create(:order_item, product: sally_product2) }
  let!(:order2) { create(:order, items: [order2_item1], market: mini_market, organization: buyer_organization) }
end
