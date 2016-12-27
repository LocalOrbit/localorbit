require "spec_helper"

describe "Adding advanced pricing" do
  let(:user)          { create(:user, :supplier) }
  let(:market)        { create(:market, :with_delivery_schedule) }
  let(:market2)       { create(:market, :with_delivery_schedule) }
  let(:market3)       { create(:market, :with_delivery_schedule, allow_product_fee: true)}
  let!(:organization) { create(:organization, :seller, markets: [market, market2], users: [user]) }
  # KXM When running :185 (only?), this line throws an 'Market expected, got NilClass' error
  let!(:organization2) { create(:organization, :buyer, markets: [market, market2], users: [user]) }
  let!(:product)      { create(:product, organization: organization) }
  let!(:user2)         { create(:user, :market_manager, managed_markets: [market]) }


  before do
    organization2.market_organizations.each do |mo|
      mo.deleted_at = Time.now
      mo.save!
    end

    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
    within "#admin-nav" do

      click_link "Products"
    end
    click_link product.name
    click_link "Pricing"
  end

  it "shows there are no prices for the selected product" do
    expect(page).to have_content("You don't have any Prices for boxes of #{product.name} yet!")
  end

  it "completes successfully given valid information" do
    fill_in "price[sale_price]", with: "1.90" # 5.9% fees
    click_button "Add"

    record = Dom::PricingRow.first
    expect(record.market).to eq("All Markets")
    expect(record.buyer).to eq("All Buyers")
    expect(record.min_quantity).to eq("1")
    expect(record.net_price).to eq("$1.79") # 1.90 - (5.9% of 1.90)
    expect(record.sale_price).to eq("$1.90")

    expect(page).to_not have_content("You don't have any Prices yet!")
  end

  describe "invalid input" do 
    before do
      fill_in "price[sale_price]", with: "0"
      fill_in "price[min_quantity]", with: "0"
      click_button "Add"
    end

    it "shows error messages" do
      expect(page).to have_content("Sale price must be greater than 0")
      expect(page).to have_content("Minimum quantity must be greater than 0")
    end

    it "re-enables the net pricing calculator for the new form", js: true do
      fill_in "price[sale_price]", with: "12"
      new_price_form = Dom::NewPricingForm.first
      expect(new_price_form.net_price.value).to eq("11.29") # 5.9% fees subtracted
    end
  end

  describe "entering duplicate pricing" do
    it "shows an error" do
      fill_in "price[min_quantity]", with: "2"
      fill_in "price[sale_price]", with: "1.99"
      click_button "Add"

      fill_in "price[min_quantity]", with: "2"
      fill_in "price[sale_price]", with: "1.50"
      click_button "Add"

      expect(page).to have_content("Minimum quantity must be unique")
    end

    it "allowed for different buyers" do
      fill_in "price[min_quantity]", with: "2"
      fill_in "price[sale_price]", with: "1.99"
      click_button "Add"

      select organization.name, from: "price[organization_id]"
      fill_in "price[min_quantity]", with: "2"
      fill_in "price[sale_price]", with: "1.50"
      click_button "Add"

      expect(page).to_not have_content("Minimum quantity must be unique")
      expect(page).to have_content("Successfully added a new price")
    end

    it "allowed for different markets" do
      fill_in "price[min_quantity]", with: "2"
      fill_in "price[sale_price]", with: "1.99"
      click_button "Add"

      select market2.name, from: "price[market_id]"
      fill_in "price[min_quantity]", with: "2"
      fill_in "price[sale_price]", with: "1.50"
      click_button "Add"

      expect(page).to_not have_content("Minimum quantity must be unique")
      expect(page).to have_content("Successfully added a new price")
    end
  end

  describe "pricing for a specific buyer" do
    it "saves the buyer" do
      fill_in "price[sale_price]", with: "1.99"
      select organization.name, from: "price[organization_id]"
      click_button "Add"

      record = Dom::PricingRow.first
      expect(record.market).to eq("All Markets")
      expect(record.buyer).to eq(organization.name)
      expect(record.min_quantity).to eq("1")
      expect(record.net_price).to eq("$1.87") # 5.9 % fees
      expect(record.sale_price).to eq("$1.99")
    end

    it "excludes inactive buyers" do
      expect(page).to_not have_select("price[organization_id]", :options => ["All Buyers", "Organization 4", "Organization 5"])
    end
  end

  it "canceling adding a price", js: true do
    fill_in "price[min_quantity]", with: "2"
    fill_in "price[sale_price]", with: "1.99"
    click_button "Add"

    click_link "Add Price"
    fill_in "price[sale_price]", with: "1.90"
    click_button "Cancel"


    click_link "Add Price"
    expect(find_field("price[sale_price]").value).to eq("")
  end

  it "hides the new form if you start editing a price but retains entered values", js: true do
    fill_in "price[min_quantity]", with: "2"
    fill_in "price[sale_price]", with: "1.99"
    click_button "Add"

    click_link "Add Price"
    expect(Dom::NewPricingForm.first).not_to be_nil
    fill_in "price[sale_price]", with: "1.90"
    Dom::PricingRow.first.click_edit

    expect(Dom::NewPricingForm.first).to be_nil

    click_button "Cancel"
    click_link "Add Price"
    expect(Dom::NewPricingForm.first).not_to be_nil
    expect(find_field("price[sale_price]").value).to eq("1.90")
  end

  describe "with different fees", js: true do
    let(:market) { create(:market, local_orbit_seller_fee: 4, market_seller_fee: 6) }

    it "shows updated net sale information" do
      fill_in "price[sale_price]", with: "12.90"
      expect(find_field("price[net_price]").value).to eq("11.24") # 12.9% fees subtracted
      click_button "Add"

      expect(page).to have_content("Successfully added a new price")

      record = Dom::PricingRow.first
      expect(record.market).to eq("All Markets")
      expect(record.buyer).to eq("All Buyers")
      expect(record.min_quantity).to eq("1")
      expect(record.net_price).to eq("$11.24") # 12.9% fees subtracted
      expect(record.sale_price).to eq("$12.90")
    end
  end

  describe "with category market fees - single market", js: true do
    let!(:market) { create(:market, :with_delivery_schedule, :with_category_fee, allow_product_fee: true) }
    let!(:market2){}
    let!(:user)   { create(:user, :market_manager) }
    let!(:organization) { create(:organization, :seller, markets: [market], users: [user]) }

    it "shows updated net sale information - product fee" do
      find(:field, 'price[fee]', with: '1').click
      fill_in "price[sale_price]", with: "12.90"

      expect(find_field("price[net_price]").value).to eq("10.98")
      click_button "Add"

      expect(page).to have_content("Successfully added a new price")

      record = Dom::PricingRow.first
      expect(record.market).to eq("All Markets")
      expect(record.buyer).to eq("All Buyers")
      expect(record.min_quantity).to eq("1")
      expect(record.net_price).to eq("$10.98")
      expect(record.fee).to eq("Use Category Fee")
      expect(record.sale_price).to eq("$12.90")
    end
  end

  describe "with category market fees - multiple markets", js: true do
    let(:market) { create(:market, :with_delivery_schedule, :with_category_fee, allow_product_fee: true) }
    let(:user)   { create(:user, :market_manager) }

    it "shows updated net sale information - product fee" do
      find(:field, 'price[fee]', with: '1').click
      fill_in "price[sale_price]", with: "12.90"

      expect(find_field("price[net_price]").value).to eq("12.53")
      click_button "Add"

      expect(page).to have_content("Successfully added a new price")

      record = Dom::PricingRow.first
      expect(record.notice).to eq("Needs Review")
      expect(record.market).to eq("All Markets")
      expect(record.buyer).to eq("All Buyers")
      expect(record.min_quantity).to eq("1")
      expect(record.net_price).to eq("$12.14")
      expect(record.sale_price).to eq("$12.90")
    end
  end

  describe "with product market fees", js: true do
    let(:market) { create(:market, :with_delivery_schedule, allow_product_fee: true) }
    let(:user)   { create(:user, :market_manager) }

    it "shows updated net sale information - product fee" do
      find(:field, 'price[fee]', with: '2').click
      fill_in "price[product_fee_pct]", with: "20"
      fill_in "price[sale_price]", with: "12.90"

      expect(find_field("price[net_price]").value).to eq("9.95")
      click_button "Add"

      expect(page).to have_content("Successfully added a new price")

      record = Dom::PricingRow.first
      expect(record.market).to eq("All Markets")
      expect(record.buyer).to eq("All Buyers")
      expect(record.min_quantity).to eq("1")
      expect(record.net_price).to eq("$9.95")
      expect(record.fee).to eq("20.000%")
      expect(record.sale_price).to eq("$12.90")
    end
=begin
    it "shows updated net sale information" do
      find(:field, 'price[fee]', with: '1').click
      fill_in "price[net_price]", with: "9.95"

      check 'price[lock]', visible: false
      # find(:field, 'price[lock]', visible: false).click
      fill_in "price[sale_price]", with: "12.90"

      expect(find_field("price[product_fee_pct]").value).to eq("20")
      click_button "Add"

      expect(page).to have_content("Successfully added a new price")

      record = Dom::PricingRow.first
      expect(record.market).to eq("All Markets")
      expect(record.buyer).to eq("All Buyers")
      expect(record.min_quantity).to eq("1")
      expect(record.net_price).to eq("$9.95")
      expect(record.fee).to eq("20.000%")
      expect(record.sale_price).to eq("$12.90")
    end
=end
  end
end
