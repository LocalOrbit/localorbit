require "spec_helper"

describe "Adding advanced pricing" do
  let(:user)          { create(:user) }
  let(:market)        { create(:market) }
  let(:market2)       { create(:market) }
  let!(:organization) { create(:organization, markets: [market, market2], users: [user]) }
  let!(:product)      { create(:product, organization: organization) }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
    within "#admin-nav" do
      click_link "Products"
    end
    click_link product.name
    click_link "Pricing"
  end

  it "shows there are no prices for the selected product" do
    expect(page).to have_content("You don't have any prices yet!")
  end

  it "completes successfully given valid information" do
    fill_in "price_sale_price", with: "1.90"
    click_button "Add"

    record = Dom::PricingRow.first
    expect(record.market).to eq("All Markets")
    expect(record.buyer).to eq("All Buyers")
    expect(record.min_quantity).to eq("1")
    expect(record.net_price).to eq("$1.79")
    expect(record.sale_price).to eq("$1.90")

    expect(page).to_not have_content("You don't have any prices yet!")
  end

  describe "invalid input" do
    before do
      fill_in "price_sale_price", with: "0"
      fill_in "price_min_quantity", with: "0"
      click_button "Add"
    end

    it "shows error messages" do
      expect(page).to have_content("Sale price must be greater than 0")
      expect(page).to have_content("Minimum quantity must be greater than 0")
    end

    it "re-enables the net pricing calculator for the new form", js: true do
      fill_in "price_sale_price", with: "12"

      new_price_form = Dom::NewPricingForm.first
      expect(new_price_form.net_price.value).to eql("11.28")
    end
  end

  describe "entering duplicate pricing" do
    it "shows an error" do
      fill_in "price_min_quantity", with: "2"
      fill_in "price_sale_price", with: "1.99"
      click_button "Add"

      fill_in "price_min_quantity", with: "2"
      fill_in "price_sale_price", with: "1.50"
      click_button "Add"

      expect(page).to have_content("Minimum quantity must be unique")
    end

    it "allowed for different buyers" do
      fill_in "price_min_quantity", with: "2"
      fill_in "price_sale_price", with: "1.99"
      click_button "Add"

      select organization.name, from: "price_organization_id"
      fill_in "price_min_quantity", with: "2"
      fill_in "price_sale_price", with: "1.50"
      click_button "Add"

      expect(page).to_not have_content("Minimum quantity must be unique")
      expect(page).to have_content("Successfully added a new price")
    end

    it "allowed for different markets" do
      fill_in "price_min_quantity", with: "2"
      fill_in "price_sale_price", with: "1.99"
      click_button "Add"

      select market2.name, from: "price_market_id"
      fill_in "price_min_quantity", with: "2"
      fill_in "price_sale_price", with: "1.50"
      click_button "Add"

      expect(page).to_not have_content("Minimum quantity must be unique")
      expect(page).to have_content("Successfully added a new price")
    end
  end

  describe "pricing for a specific buyer" do
    it "saves the buyer" do
      fill_in "price_sale_price", with: "1.99"
      select organization.name, from: "price_organization_id"
      click_button "Add"

      record = Dom::PricingRow.first
      expect(record.market).to eq("All Markets")
      expect(record.buyer).to eq(organization.name)
      expect(record.min_quantity).to eq("1")
      expect(record.net_price).to eq("$1.87")
      expect(record.sale_price).to eq("$1.99")
    end
  end

  it "canceling adding a price", js: true do
    fill_in "price_min_quantity", with: "2"
    fill_in "price_sale_price", with: "1.99"
    click_button "Add"

    click_link "Add Price"
    fill_in "price_sale_price", with: "1.90"
    click_button "Cancel"

    click_link "Add Price"
    expect(find_field("price_sale_price").value).to eq("")
  end

  it "hides the new form if you start editing a price but retains entered values", js: true do
    fill_in "price_min_quantity", with: "2"
    fill_in "price_sale_price", with: "1.99"
    click_button "Add"

    click_link "Add Price"
    expect(Dom::NewPricingForm.first).not_to be_nil
    fill_in "price_sale_price", with: "1.90"
    Dom::PricingRow.first.click_edit

    expect(Dom::NewPricingForm.first).to be_nil

    click_button "Cancel"
    click_link "Add Price"
    expect(Dom::NewPricingForm.first).not_to be_nil
    expect(find_field("price_sale_price").value).to eq("1.90")
  end

  describe "with different fees", js: true do
    let(:market) { create(:market, local_orbit_seller_fee: 4, market_seller_fee: 6) }

    it "shows updated net sale information" do
      fill_in "price_sale_price", with: "12.90"
      expect(find_field("price_net_price").value).to eq("11.22")
      click_button "Add"

      expect(page).to have_content("Successfully added a new price")

      record = Dom::PricingRow.first
      expect(record.market).to eq("All Markets")
      expect(record.buyer).to eq("All Buyers")
      expect(record.min_quantity).to eq("1")
      expect(record.net_price).to eq("$11.22")
      expect(record.sale_price).to eq("$12.90")
    end
  end
end
