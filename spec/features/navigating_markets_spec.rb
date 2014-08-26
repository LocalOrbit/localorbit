require "spec_helper"

feature "A user navagating markets" do
  let(:seller_org) { create(:organization, :seller) }
  let(:buyer_org) { create(:organization, :buyer, :single_location) }
  let(:user) { create(:user, organizations: [buyer_org]) }

  context "without a market" do
    scenario "a visitor sees the base domain" do
      visit "/"
      expect(page).to have_content("Please Sign In")
      expect(page).to have_css("img[src='/assets/logo.png']")
    end

    scenario "a visitor sees the 'app' domain" do
      switch_to_subdomain "app"
      visit "/"
      expect(page).to have_content("Please Sign In")
      expect(page).to have_css("img[src='/assets/logo.png']")
    end

    scenario "a visitor to a non-existant subdomain is redirected to the 'app' domain" do
      switch_to_subdomain "not-real-ever"
      visit "/"
      host = URI.parse(page.current_host).host
      expect(host).to eq("app.#{Figaro.env.domain}")
    end

    scenario "a visitor to a market subdomain sees the sign in page" do
      market = create(:market, :with_logo)
      switch_to_subdomain market.subdomain
      visit "/"
      host = URI.parse(page.current_host).host
      expect(host).to eq(market.domain)
      # expect(page).to have_content(market.name)
      # expect(page).to have_content(market.tagline)
      expect(page).to have_css("img[src='#{market.logo.thumb("600x200>").url}']")
    end
  end

  context "a user with one market" do
    let!(:market) { create(:market, :with_logo, organizations: [seller_org, buyer_org]) }

    scenario "a user navigating to their market" do
      visit "/"
      expect(page).not_to have_content(market.name)
      expect(page).to have_content("Please Sign In")
      expect(page).to have_css("img[src='/assets/logo.png']")

      switch_to_subdomain market.subdomain
      visit "/"
      # expect(page).to have_content(market.name)
      expect(page).to have_content("Please Sign In")
      expect(page).to have_css("img[src='#{market.logo.thumb("600x200>").url}']")

      sign_in_as(user)
      expect(page).to have_content(market.name)
      expect(page).to have_content(market.tagline)
      expect(page).to have_content("Welcome #{user.email}")
      expect(page).to have_css("img[src='#{market.logo.thumb("600x200>").url}']")
    end
  end

  context "a user with one market on a unicode domain" do
    let!(:market) { create(:market, subdomain: "👍", organizations: [seller_org, buyer_org]) }

    scenario "a user navigating to their market" do
      switch_to_subdomain SimpleIDN.to_ascii(market.subdomain)
      visit "/"
      # expect(page).to have_content(market.name)

      sign_in_as(user)
      expect(page).to have_content(market.name)
      expect(page).to have_content(market.tagline)
      expect(page).to have_content("Welcome")
    end
  end

  context "signing in" do
    let!(:market) { create(:market, organizations: [seller_org, buyer_org]) }
    let!(:delivery_schedule) { create(:delivery_schedule, market: market) }

    context "on a subdomain" do
      it "shows me the products page" do
        switch_to_subdomain market.subdomain
        sign_in_as(user)

        within(".header", match: :first) do
          expect(page).to have_content(market.name)
        end

        expect(current_path).to eql("/products")
      end
    end

    context "on the main domain" do
      it "redirects to the products page if the user has only 1 market" do
        switch_to_main_domain
        sign_in_as(user)

        within(".header", match: :first) do
          expect(page).to have_content(market.name)
        end

        expect(current_path).to eql("/products")
      end

      it "shows something to let me pick a market if the user has multiple markets"
    end
  end
end
