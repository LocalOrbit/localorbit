require 'spec_helper'

describe ::Financials::Pricing do
	subject(:subject) { described_class }	
	let!(:market1) {create(:market)}
	let!(:market2) {create(:market, local_orbit_seller_fee:10)}

	it "gets seller net percents by market" do 
		mkts = [market1,market2]
		res = ::Financials::Pricing.seller_net_percents_by_market(mkts)
		expect(res[market1.id.to_s]).to eq(market1.seller_net_percent)
		expect(res[market2.id.to_s]).to eq(market2.seller_net_percent)
	end

	it "correctly gets worst case scenario for the all case" do
		mkts = [market1,market2]
		res = ::Financials::Pricing.seller_net_percents_by_market(mkts)
		expect(res["all"]).to eq(market2.seller_net_percent)
	end
end

