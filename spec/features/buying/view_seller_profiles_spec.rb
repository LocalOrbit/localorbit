require "spec_helper"

feature "View Seller Profiles" do
  let!(:buyer)   { create(:organization, :buyer, :single_location) }
  let!(:seller1) { create(:organization, :seller, :single_location, who_story: "Funny Farm", how_story: "Via a wagon") }
  let!(:seller2) { create(:organization, :seller, :single_location) }
  let!(:inactive_seller) { create(:organization, :seller, :single_location, active: false) }
  let!(:hidden_seller) { create(:organization, :seller, :single_location, show_profile: false) }
  let!(:user)    { create(:user, :buyer, organizations: [buyer]) }
  let!(:market)  { create(:market, :with_addresses, organizations: [buyer, seller1, seller2, hidden_seller]) }
  let!(:delivery_schedule) { create(:delivery_schedule, market: market) }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
  end

  context "when user has multiple organizations" do
    before do
      user.organizations << create(:organization, :single_location, :buyer, markets: [market])
      user.save
    end

    scenario "redirects to organization select page" do
      click_link "Suppliers", match: :first

      expect(page).to have_content("Select a Buyer")
      select buyer.name, from: "org_id"
      click_button "Select Buyer"

      expect(page).to have_content(seller1.name)
    end

    context "but is suspended from all but one" do
      before do
        suspend_user(user: user, org: user.organizations.last)
      end

      scenario "does not redirect" do
        click_link "Suppliers", match: :first

        expect(page).not_to have_content("Select a Buyer")
        expect(page).to have_content("Date Change Confirmation")
      end
    end
  end

  context "when no sellers are in the market" do
    before do
      market.organizations = [buyer]
      market.save!
    end

    scenario "no sellers in market" do
      switch_to_subdomain(market.subdomain)

      click_link "Suppliers", match: :first
      expect(page).to have_content("#{market.name} has no Sellers at this time.")
    end

  end

  scenario "view list of sellers" do
    click_link "Suppliers", match: :first

    expect(page).to have_content(seller1.name)
    expect(page).to have_content(seller2.name)
    expect(page).to_not have_content(inactive_seller.name)
    expect(page).to_not have_content(hidden_seller.name)
    expect(page).to have_css("#admin-nav", visible: false)
  end

  context "seller profile" do
    scenario "view a sellers profile" do
      click_link "Suppliers", match: :first
      click_link seller1.name

      expect(page).to have_content(seller1.who_story)
      expect(page).to have_content(seller1.how_story)
      expect(page).to have_css("#admin-nav", visible: false)
      expect(page).to_not have_xpath("//a[@class='twitter-timeline' and @data-screen-name='#{seller1.twitter}']")
      expect(page).to_not have_xpath("//div[@class='fb-like-box' and @data-href='https://www.facebook.com/#{seller1.facebook}']")
    end

    it "displays a twitter feed if enabled for the seller" do
      seller1.update(display_twitter: true, twitter: "localorbit")

      visit seller_path(seller1)

      expect(page).to have_xpath("//a[@class='twitter-timeline' and @data-screen-name='#{seller1.twitter}']")
    end

    it "displays a facebook feed if enabled for the seller" do
      seller1.update(display_facebook: true, facebook: "localorbit")

      visit seller_path(seller1)

      expect(page).to have_xpath("//div[@class='fb-like-box' and @data-href='https://www.facebook.com/#{seller1.facebook}']")
    end
  end

  context "available products", :js do
    let!(:product1)       { create(:product, :sellable, organization: seller1) }
    let!(:product2)       { create(:product, organization: seller1) }
    let!(:product3)       { create(:product, :sellable, organization: seller2) }

    scenario "view a sellers offerings" do
      visit seller_path(seller1)
      sleep 10

      click_link "View Products"

      #expect(page).to have_content ("Currently Selling")

      products = Dom::NewProduct.all
      expect(products.count).to eq(1)
      expect(products.map(&:name)).to match_array([product1.name])
    end

    scenario "changing selected delivery" do
      visit seller_path(seller1)
      sleep 10
      #expect(page).to have_css ('#change-delivery-date')

      #Dom::Buying::SelectedDelivery.first.click_change
      #expect(page).to have_content("Please choose a pick up or delivery date")

      #Dom::Buying::DeliveryChoice.first.choose!

      expect(page).to have_content(seller1.who_story)
      expect(page).to have_content(seller1.how_story)

      click_link "View Products"

      products = Dom::NewProduct.all
      expect(products.count).to eq(1)
      expect(products.map(&:name)).to match_array([product1.name])
    end
  end

  context "no available products", :js do
    scenario "no offerings" do
      visit seller_path(seller1)

      expect(page).to_not have_content("Currently Selling")
    end
  end

  context "product categories", :js do
    let!(:product1) { create(:product, :sellable, organization: seller1, category: Category.find_by(name: "Empire Apples")) }
    let!(:product2) { create(:product, :sellable, organization: seller1, category: Category.find_by(name: "Macintosh Apples")) }
    let!(:product3) { create(:product, :sellable, organization: seller1, category: Category.find_by(name: "Macintosh Apples")) }
    let!(:product2) { create(:product, :sellable, organization: seller1, category: Category.find_by(name: "Bananas")) }

    scenario "viewing the products with their categories" do
      visit seller_path(seller1)
      sleep 10
      click_link "View Products"

      #expect(page).to have_content ("Currently Selling")

      products = Dom::NewProduct.all
      expect(products.count).to eq(3)
      # two inner headers (apples/bananas)
      expect(page).to have_content ("Apples")
      expect(page).to have_content ("Bananas")
    end
  end

end
