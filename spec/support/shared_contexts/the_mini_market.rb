shared_context "the mini market" do
  let!(:mini_market) { create(:market, name: "Mini Market") }
  let!(:mary) { create(:user, :market_manager, name: "Mary", managed_markets: [mini_market]) }

  let!(:sally) { create(:user, name: "Sally") }
  let!(:seller_organization) { create(:organization, :seller, users: [sally], markets:[mini_market]) }

  let!(:barry) { create(:user, name: "Barry") }
  let!(:buyer_organization) { create(:organization, :buyer, users: [barry], markets:[mini_market]) }
end
