require "spec_helper"

context "As a market manager", :permissions, :market_manager do
  let!(:user) { create(:user) }
  let!(:market2) { create(:market) }
  let!(:market1) { create(:market, managers: [user]) }
 
  let!(:org) { create(:organization, markets: [market2], users: [user]) }

  context "belonging to an organization in anoter market" do
    context "and the organization is removed" do
      before do
        mo = MarketOrganization.find_by(market: market2, organization: org)
        mo.soft_delete
      end

      context "when logging into the application URL with no subdomain" do
        it "redirects to the market manager's managed market" do
          switch_to_subdomain("app")
          sign_in_as user
          url = URI.parse(current_url)
          expect(url.to_s).to match(/#{market1.subdomain}/)
        end
      end

      context "when logging into the subdomain of the organization's former market" do
        it "shows a 404" do
          switch_to_subdomain(market2.subdomain)
          sign_in_as user
          expect(page.status_code).to eq(404)
        end
      end
    end
  end
end
