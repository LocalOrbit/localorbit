require "spec_helper"

context "As an organization member", :permissions, :organization_member do
  let!(:user) { create(:user) }
  let!(:market2) { create(:market) }
  let!(:market1) { create(:market) }

  let!(:org1) { create(:organization, users: [user], markets: [market1]) }
  let!(:org2) { create(:organization, users: [user], markets: [market2]) }

  context "belonging to an organization in anoter market" do
    context "and the organization is removed" do
      before do
        mo = MarketOrganization.find_by(market: market2, organization: org2)
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
