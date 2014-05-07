require "spec_helper"

describe MarketMailer do
  describe "fresh_sheet" do
    let!(:fulton_farms) { create(:organization, :seller, name: "Fulton St. Farms") }
    let!(:ada_farms)    { create(:organization, :seller, name: "Ada Farms") }

    let!(:market_in)  { create(:market, organizations: [fulton_farms], contact_phone: "616-123-4567") }
    let!(:market_out) { create(:market, organizations: [ada_farms]) }

    let!(:product_in)  { create(:product, :sellable, organization: fulton_farms) }
    let!(:product_out) { create(:product, :sellable, organization: ada_farms) }

    before do
      [market_in, market_out].each do |market|
        create(:delivery, delivery_schedule: create(:delivery_schedule,  market: market))
      end
    end

    it "only shows products for the given market" do
      fresh_sheet = MarketMailer.fresh_sheet(market_in)
      expect(fresh_sheet.body).to include(product_in.name)
      expect(fresh_sheet.body).to include(product_in.organization.name)

      expect(fresh_sheet.body).not_to include(product_out.name)
      expect(fresh_sheet.body).not_to include(product_out.organization.name)

      expect(fresh_sheet.body).to include("For customer service please reply to this email")
      expect(fresh_sheet.body).to include("616-123-4567")
    end
  end
end
