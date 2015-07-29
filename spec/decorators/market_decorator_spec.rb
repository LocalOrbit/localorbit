require "spec_helper"

# TODO: add tests for remaining decorator methods

describe "MarketDecorator" do
  let!(:market) { create(:market, :with_address) }

  it "Gets first addresses if none are set for default or billing" do
    expect(market.decorate.default_address.address).to eq("44 E. 8th St")
    expect(market.decorate.billing_address.address).to eq("44 E. 8th St")
  end

  describe "Market decorator address methods" do
    let!(:address1) { create(:market_address, market: market, address:"123 New Address St", city: "Grand Rapids", phone: "(616) 555-1255", default:true) }
    let!(:address2) { create(:market_address, market: market, address: "1234 Billing Address St", city: "Lansing", phone: "(616) 555-5512", billing:true) }
    
    it "allows address decorators to work correctly" do
      #let!(:market) { create(:market, :with_address) }
      expect(market.decorate.default_address.address).to eq("123 New Address St")
      expect(market.decorate.billing_address.address).to eq("1234 Billing Address St")
      expect(market.decorate.billing_street_address).to eq("1234 Billing Address St")
      expect(market.decorate.billing_city_state_zip).to eq("Lansing, MI 49423")
      expect(market.decorate.billing_address_phone_number).to eq("(616) 555-5512")
      expect(market.decorate.default_address_phone_number).to eq("(616) 555-1255")
      expect(market.decorate.display_contact_phone).to eq("(616) 222-2222")
    end
  end

end