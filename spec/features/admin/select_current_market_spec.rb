require "spec_helper"

feature "Selecting a market" do
  let!(:admin) { create(:user, :admin) }

  before do
    sign_in_as(admin)
    switch_to_main_domain
  end

  # This case seems odd as long as the market picker is only for admins,
  # but this test was written retroactively based on the current behavior.
  # It would make more sense if a market picker were used for everyone.
  context "single market" do
    let!(:market) { create(:market) }

    it "redirects to that market automatically" do
      visit market_path
      expect(current_host).to include(market.subdomain)
    end
  end

  context "multiple markets" do
    let!(:market1) { create(:market) }
    let!(:market2) { create(:market) }

    it "does nothing if already on a subdomain" do
      switch_to_subdomain(market2.subdomain)
      visit market_path
      expect(current_host).to include(market2.subdomain)
    end

    it "displays a dialog to choose" do
      visit market_path
      expect(page).to have_content("Please Select a Market")
      click_link market2.name
      expect(current_host).to include(market2.subdomain)
    end
  end
end
