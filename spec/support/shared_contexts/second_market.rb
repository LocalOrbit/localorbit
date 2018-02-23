shared_context 'second market' do
  let!(:second_market_plan) {create(:plan, :grow) }
  let!(:second_market_org) { create(:organization, :market, plan: second_market_plan)}
  let!(:second_market) { create(:market, name: "Second Market", organization: second_market_org) }

  let!(:larry) { create(:user, :buyer, name: "Larry Libra") }
  let!(:buyer2_organization) { create(:organization, :buyer, name: larry.name, users: [larry], markets:[second_market]) }
end
