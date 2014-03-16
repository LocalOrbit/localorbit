require 'spec_helper'

feature "A user navagating markets" do
  let(:seller_org) { create(:organization, :seller) }
  let(:buyer_org) { create(:organization, :buyer) }
  let(:user) { create(:user, organizations: [buyer_org]) }

  context "without a market" do
    scenario "a visitor sees the base domain" do
      visit '/'
      expect(page).not_to have_content("Welcome")
      expect(page).to have_css("img[src='/assets/logo.png']")
    end

    scenario "a visitor to a non-existant subdomain is redirected to the base domain" do
      switch_to_subdomain "not-real-ever"
      visit '/'
      host = URI.parse(page.current_host).host
      expect(host).to eq(Figaro.env.domain)
    end

    scenario "a visitor to a subdomain sees the sign in page" do
      market = create(:market, :with_logo)
      switch_to_subdomain market.subdomain
      visit '/'
      host = URI.parse(page.current_host).host
      expect(host).to eq(market.domain)
      # expect(page).to have_content(market.name)
      expect(page).to have_css("img[src='#{market.logo.remote_url}']")
    end
  end

  context "a user with one market" do
    let!(:market) { create(:market, :with_logo, organizations: [seller_org, buyer_org]) }

    scenario "a user navigating to their market" do
      visit '/'
      expect(page).not_to have_content(market.name)
      expect(page).not_to have_content("Welcome")
      expect(page).to have_css("img[src='/assets/logo.png']")

      switch_to_subdomain market.subdomain
      visit '/'
      # expect(page).to have_content(market.name)
      expect(page).not_to have_content("Welcome")
      expect(page).to have_css("img[src='#{market.logo.remote_url}']")

      sign_in_as(user)
      expect(page).to have_content(market.name)
      expect(page).to have_content("Welcome")
      expect(page).to have_css("img[src='#{market.logo.remote_url}']")
    end
  end
end
