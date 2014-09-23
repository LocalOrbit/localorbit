puts "HITHERE the fresh market LOADED!"
shared_context "the fresh market" do
  let!(:fresh_market) { create(:market, name: "Fresh Market") }
  let!(:mary) { create(:user, :market_manager, name: "Mary", managed_markets: [fresh_market]) }
  let!(:marvin) { create(:user, :market_manager, name: "Marvin", managed_markets: [fresh_market]) }
  let!(:bill) { create(:user, name:"Bill") }
  let!(:barry) { create(:user, name:"Barry") }
  let!(:basil) { create(:user, name:"Basil") }
  let!(:steve) { create(:user, name:"Steve") }
  let!(:sol) { create(:user, name:"Sol") }
  let!(:scarbro) { create(:user, name:"Scarbro") }
  let!(:clarence) { create(:user, name:"Clarence") }
  let!(:b1) { create(:organization, :buyer, users:[bill,barry], markets:[fresh_market]) }
  let!(:b2) { create(:organization, :buyer, users:[barry,basil], markets:[fresh_market]) }
  let!(:b3) { create(:organization, :buyer, users:[clarence], markets:[fresh_market]) }
  let!(:s1) { create(:organization, :seller, users: [steve,basil], markets:[fresh_market]) }
  let!(:s2) { create(:organization, :seller, users: [sol], markets:[fresh_market]) }

  let!(:other_market) { create(:market, name: "Other Market") }
  let!(:marcus) { create(:user, :market_manager, name: "Marcus", managed_markets: [other_market]) }
  let!(:craig) { create(:user, name:"Craig") }
  let!(:b4) { create(:organization, :buyer, users:[craig], markets:[other_market]) }
  let!(:s3) { create(:organization, :seller, users: [scarbro], markets:[other_market]) }

  before do
    # Break Clarence's and Sol's organizations away from their markets:
    [sol,clarence].each do |user|
      user.organizations.first.market_organizations.first.soft_delete
    end
  end
end
