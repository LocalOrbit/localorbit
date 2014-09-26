require "spec_helper"

describe MarketMailer do
  describe "fresh_sheet" do
    let!(:fulton_farms) { create(:organization, :seller, name: "Fulton St. Farms") }
    let!(:ada_farms)    { create(:organization, :seller, name: "Ada Farms") }

    let!(:market_in)  { create(:market, organizations: [fulton_farms], contact_phone: "616-123-4567") }
    let!(:market_out) { create(:market, organizations: [ada_farms]) }

    let!(:delivery_schedule1) { create(:delivery_schedule, market: market_in, day: 5, order_cutoff: 24, buyer_pickup_start: "12:00 PM", buyer_pickup_end: "2:00 PM") }
    let!(:delivery_schedule2) { create(:delivery_schedule, market: market_out, day: 5, order_cutoff: 24, buyer_pickup_start: "12:00 PM", buyer_pickup_end: "2:00 PM") }

    let!(:product_in)  { create(:product, :sellable, delivery_schedules: [delivery_schedule1], organization: fulton_farms) }
    let!(:product_out) { create(:product, :sellable, delivery_schedules: [delivery_schedule2], organization: ada_farms) }

    include_context "fresh sheet and newsletter subscription types"

    let!(:token) {"xyz--unsubscribe-me-987"}
    it "only shows products for the given market" do
      user = create(:user)
      fresh_sheet = MarketMailer.fresh_sheet(market: market_in, to: user.pretty_email, unsubscribe_token: token)
      expect(fresh_sheet.body).to include(product_in.name)
      expect(fresh_sheet.body).to include(product_in.organization.name)

      expect(fresh_sheet.body).not_to include(product_out.name)
      expect(fresh_sheet.body).not_to include(product_out.organization.name)

      expect(fresh_sheet.body).to include("For customer service please reply to this email")
      expect(fresh_sheet.body).to include("616-123-4567")
      expect(fresh_sheet.body).to include("Click here to")
      expect(fresh_sheet.body).to include(%|href="#{unsubscribe_subscriptions_url(host:market_in.domain, token:token)}"|)
    end

    it "displays the fresh sheet note if present" do
      fresh_sheet = MarketMailer.fresh_sheet(market: market_in, note: "Rockin")

      expect(fresh_sheet.body).to include("Rockin")
      expect(fresh_sheet.body).not_to include("Click here to")
      expect(fresh_sheet.body).not_to include(%|href="#{unsubscribe_subscriptions_url(token:token)}"|)
    end
  end
end
