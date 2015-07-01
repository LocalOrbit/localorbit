require "spec_helper"

describe "Market Address functionality" do
  let!(:market) { create(:market) }
  #subject = create(:market_address, name: "test", market: market)

### possibly this should all be in managing_market_addresses_spec

	# it "displays the default and billing properly" do
	# 	# visit path to click into form?
	# 	# check that form text is correctly on page
	# end

	# it "sets default and billing properly" do
 #    # submit an address with default and billing
 #    # check that that address has default and billing vals true in db
 #  end

 #  it "sets default to newly selected default only" do
 #    # set up address with a default true
 #    # submit new address with default
 #    # check that new address is the only default
 #  end
 
 #  it "sets billing to newly selected billing addr only", js:true do
 #  	# need to do this via phantom js instead...

 #    # subject = create(:market_address, name: "test", market: market, billing: true)
 #    # new_billing = create(:market_address, name: "test2", market: market, billing: true)
 #    # expect(market.addresses.visible.map{|mkt| mkt if mkt.billing}.first).to eq(new_billing)
 #    # expect(subject.billing).to eq(false)
 #  end

  it "does not access soft-deleted defaults as default" do
  	subject = create(:market_address, name: "test", market: market, default: true, deleted_at: 1.day.ago)
  	new_default = create(:market_address, name: "test2", market: market, default: true)
  	expect(market.addresses.visible.map{|mkt| mkt if mkt.default}.first).to eq(new_default)
  end

  # possible - test whether default address is going to About page
  # possible - test whether billing address is going to Invoice(s)
end