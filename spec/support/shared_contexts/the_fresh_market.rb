shared_context "the fresh market" do

  let!(:b1) { create(:organization, :buyer) }
  let!(:b2) { create(:organization, :buyer) }
  let!(:b3) { create(:organization, :buyer) }
  let!(:b4) { create(:organization, :buyer) }

  let!(:s1) { create(:organization, :seller) }
  let!(:s2) { create(:organization, :seller) }
  let!(:s3) { create(:organization, :seller) }

  let!(:fresh_market) { create(:market, name: "Fresh Market", organizations:[b1,b2,b3,s1,s2]) }
  let!(:other_market) { create(:market, name: "Other Market", organizations: [b4]) }

  let!(:marcus) { create(:user, :market_manager, name: "Marcus", managed_markets: [other_market]) }


  let!(:mary) { create(:user, :market_manager, name: "Mary", managed_markets: [fresh_market]) }
  let!(:marvin) { create(:user, :market_manager, name: "Marvin", managed_markets: [fresh_market]) }

  let!(:bill) { create(:user, :buyer, name:"Bill", organizations: [b1]) }
  let!(:barry) { create(:user, :buyer, name:"Barry", organizations: [b1,b2]) }
  let!(:basil) { create(:user, :buyer, name:"Basil", organizations: [b2,s1]) }
  let!(:clarence) { create(:user, :buyer, name:"Clarence", organizations: [b3]) }
  let!(:craig) { create(:user, :buyer, name:"Craig", organizations:[b4]) }
  let!(:sol) { create(:user, :buyer, name:"Sol", organizations: [s2]) }

  let!(:steve) { create(:user, :supplier, name:"Steve", organizations: [s1]) }
  let!(:scarbro) { create(:user, :supplier, name:"Scarbro", organizations: [s3]) }

  before do
    # Break Clarence's and Sol's organizations away from their markets:
    [sol,clarence].each do |user|
      user.organizations.first.market_organizations.first.soft_delete
    end
  end
end
