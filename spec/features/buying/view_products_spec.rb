require "spec_helper"

feature "Viewing products", :js do
  let!(:market) { create(:market, :with_addresses) }
  let!(:delivery_schedule1) { create(:delivery_schedule, :buyer_pickup,
                                     market: market,
                                     order_cutoff: 24,
                                     day: 5,
                                     buyer_pickup_location_id: 0,
                                     buyer_pickup_start: "12:00 PM",
                                     buyer_pickup_end: "2:00 PM") }
  let!(:delivery_schedule2) { create(:delivery_schedule, market: market, day: 3, deleted_at: Time.zone.parse("2013-03-21")) }
  let!(:delivery_schedule4) { create(:delivery_schedule, market: market, day: 3, is_recoverable: true, inactive_at: Time.zone.parse("2013-03-21")) }

  let!(:org1) { create(:organization, :seller, markets: [market]) }
  let!(:org1_product) { create(:product, :sellable, name: "celery", organization: org1, delivery_schedules: [delivery_schedule1]) }

  let!(:org2) { create(:organization, :seller, markets: [market]) }
  let!(:org2_product) { create(:product, :sellable, organization: org2, delivery_schedules: [delivery_schedule1]) }
  let!(:org2_product_deleted) { create(:product, :sellable, organization: org2, deleted_at: Time.zone.parse("2014-10-01")) }

  let!(:inactive_org) { create(:organization, :seller, active: false, markets: [market]) }
  let!(:inactive_org_product) { create(:product, :sellable, organization: inactive_org, delivery_schedules: [delivery_schedule1]) }

  let!(:other_org) { create(:organization, :seller) }
  let!(:other_products) { create_list(:product, 3, :sellable, organization: other_org) }

  let!(:buyer_org) { create(:organization, :buyer, :single_location, :buyer, markets: [market]) }
  let(:user) { create(:user, :buyer, organizations: [buyer_org]) }
  let(:market_manager) { create(:user, :market_manager, managed_markets: [market]) }

  let(:available_products) { [org1_product, org2_product] }

  def celery_item
    Dom::Cart::Item.find_by_name("celery")
  end

  def go_to_order_page
    click_link "Order", match: :first
    expect(page).to have_css('.product-catalog-category')
  end

  before do
    Timecop.travel(Time.zone.parse("October 7 2014"))
    switch_to_subdomain market.subdomain
    sign_in_as(user)
  end

  after do
    Timecop.return
  end

  context 'on the Order page' do
    before do
      go_to_order_page
    end

    it "list of products" do
      products = Dom::ProductListing.all

      within(".order-information-container") do
        expect(page).to have_content("Delivery date: Friday, Oct. 10, 2014")
      end

      expect(products).to have(2).products
      expect(products.map(&:name)).to match_array(available_products.map(&:name))

      product = available_products.first
      dom_product = Dom::ProductListing.find_by_name(product.name)

      expect(dom_product.organization_name).to have_text(product.organization_name)
      expected_price = "$%.2f" % product.prices.first.sale_price
      expect(dom_product.node).to have_content(expected_price)
    end
  end

  scenario "a product with less inventory than required to purchase" do
    skip 'This test is accurately failing but need to fix the actual bug'
    org1_product.prices.first.update(min_quantity: 200) # there are only 150
    org1_product.prices << create(:price, :past_price, min_quantity: 300) # current scope is summing total available quantity once for each price that exists.
    org1_product.prices << create(:price, :past_price, market_id: market.id,          min_quantity: 200, sale_price: 2.50)
    org1_product.prices << create(:price, :past_price, organization_id: buyer_org.id, min_quantity: 200, sale_price: 2.40)
    go_to_order_page

    expect(Dom::ProductListing.all.count).to eql(1)
    expect(Dom::ProductListing.find_by_name(org1_product.name)).to be_nil
    expect(Dom::ProductListing.find_by_name(org2_product.name)).to_not be_nil
  end

  scenario "a product with just enough inventory required to purchase" do
    org1_product.prices.first.update_column(:min_quantity, 150) # there are only 150
    org1_product.prices << create(:price, :past_price, min_quantity: 150) # current scope is summing total available quantity once for each price that exists.
    org1_product.prices << create(:price, :past_price, market_id: market.id,          min_quantity: 150, sale_price: 2.50)
    org1_product.prices << create(:price, :past_price, organization_id: buyer_org.id, min_quantity: 150, sale_price: 2.40)
    go_to_order_page

    expect(Dom::ProductListing.all.count).to eql(2)
    expect(Dom::ProductListing.find_by_name(org1_product.name)).to_not be_nil
    expect(Dom::ProductListing.find_by_name(org2_product.name)).to_not be_nil
  end

  scenario "a product with less inventory than required to purchase that is cross-sold in multiple markets" do
    skip 'This test is accurately failing but need to fix the actual bug'
    delivery_schedule1.require_delivery = true
    delivery_schedule1.save!

    delivery_schedule2.deleted_at = nil
    delivery_schedule2.save!

    org1_product.delivery_schedules << delivery_schedule2
    org1_product.save!

    org2_product.delivery_schedules << delivery_schedule2
    org2_product.save!

    org1_product.prices.first.update(min_quantity: 200) # there are only 150
    org1_product.prices << create(:price, :past_price, min_quantity: 300) # current scope is summing total available quantity once for each price that exists.
    org1_product.prices << create(:price, :past_price, market_id: market.id,          min_quantity: 200, sale_price: 2.50)
    org1_product.prices << create(:price, :past_price, organization_id: buyer_org.id, min_quantity: 200, sale_price: 2.40)

    visit new_sessions_deliveries_path
    choose_delivery "Between 12:00PM and 2:00PM"

    expect(Dom::ProductListing.all.count).to eql(1)
    expect(Dom::ProductListing.find_by_name(org1_product.name)).to be_nil
    expect(Dom::ProductListing.find_by_name(org2_product.name)).to_not be_nil
  end

  scenario "a product with inventory that expires before the delivery" do
    lot = org1_product.lots.first
    lot.update_attribute(:number, "1")
    lot.update_attribute(:expires_at, Time.zone.parse("2014-10-08"))

    go_to_order_page

    expect(Dom::ProductListing.all.count).to eql(1)
    expect(Dom::ProductListing.find_by_name(org1_product.name)).to be_nil
    expect(Dom::ProductListing.find_by_name(org2_product.name)).to_not be_nil
  end

  scenario "shows link to individual product page" do
    go_to_order_page
    product = available_products.first
    expect(page).to have_link(product.unit_plural, href: product_path(product))
  end

  context "pick up or delivery date" do
    let!(:delivery_schedule) { create(:delivery_schedule, market: market, day: 3, seller_delivery_start: "4:00 PM", seller_delivery_end: "8:00 PM") }

    before do
      delivery_schedule1.update_column(:buyer_pickup_location_id, market.addresses.first.id)
      org1_product.delivery_schedules << delivery_schedule
      visit new_sessions_deliveries_path
      expect(page).to have_content('Please choose a pick up or delivery date')
    end

    it "displays selected pick up date and location" do
      Dom::Buying::DeliveryChoice.all.last.choose!
      within(".order-information-container") do
        expect(page).to have_content("Pick up date")
        expect(page).to have_content("Friday, Oct. 10, 2014")
      end
    end

    it "displays selected delivery date and location" do
      Dom::Buying::DeliveryChoice.first.choose!

      within(".order-information-container") do
        expect(page).to have_content("Delivery date")
        expect(page).to have_content("Wednesday, Oct. 8, 2014")
      end
    end


    context "when changing selected delivery" do
      it "allows user to change" do
        Dom::Buying::DeliveryChoice.all.last.choose!

        within(".order-information-container") do
          expect(page).to have_content("Pick up date")
          expect(page).to have_content("Friday, Oct. 10, 2014")
        end

        Dom::Buying::SelectedDelivery.first.click_change

        select_option_on_singleselect('#org_id_chosen', buyer_org.name)
        click_button "Select Buyer"

        expect(page).to have_content("Please choose a pick up or delivery date")
        Dom::Buying::DeliveryChoice.first.choose!

        within(".order-information-container") do
          expect(page).to have_content("Delivery date")
          expect(page).to have_content("Wednesday, Oct. 8, 2014")
        end
      end
    end
  end

  context "single delivery schedule" do
    context "as a buyer" do
      before do
        go_to_order_page
      end

      context "multiple locations" do
        let!(:second_location) { create(:location, organization: buyer_org) }

        scenario "shows the 'change' link" do
          visit products_path
          within(".order-information-container") do
            expect(page).to have_link("Change delivery options")
          end
        end

        scenario "change delivery location after the fact"
      end

      context "single location" do
        scenario "shopping without an existing shopping cart" do
          expect(page).to have_content(org1_product.name)
        end
      end

      context "user is a member of multiple organizations" do
        let!(:buyer_org2) { create(:organization, :single_location, :buyer, markets: [market], users: [user]) }

        scenario "shows the 'change' link" do
          visit products_path
          select_option_on_singleselect('#org_id_chosen', buyer_org.name)
          click_button "Select Buyer"

          within(".order-information-container") do
            expect(page).to have_link("Change delivery options")
          end
        end
      end
    end

    context "as a market manager" do
      let(:user) { create(:user, :market_manager, managed_markets: [market]) }

      scenario "has to select an organization to shop as" do
        click_link "Order", match: :first

        select_option_on_singleselect('#org_id_chosen', buyer_org.name)
        click_button "Select Buyer"

        expect(page).to have_content(org1_product.name)
      end
    end
  end

  context "multiple delivery schedules" do
    let!(:second_location) { create(:location, organization: buyer_org) }

    let!(:ds3) do
      create(:delivery_schedule,
             day: 2,
             order_cutoff: 24,
             seller_fulfillment_location_id: 0,
             seller_delivery_start: "7:00 AM",
             seller_delivery_end:  "11:00 AM",
             market: market
    )
    end

    let!(:ds4) do
      create(:delivery_schedule,
             day: 3,
             order_cutoff: 24,
             seller_fulfillment_location: market.addresses.first,
             seller_delivery_start: "7:00 AM",
             seller_delivery_end:  "11:00 AM",
             buyer_pickup_start: "12:00 PM",
             buyer_pickup_end: "3:00 PM",
             buyer_pickup_location_id: 0,
             market: market
    )
    end

    let!(:ds3_product) { create(:product, :sellable, organization: org1, use_all_deliveries: false, delivery_schedules: [ds3]) }

    before do
      org1_product.delivery_schedules << ds4
    end

    context "direct to buyer" do
      scenario "selecting a direct to buyer delivery with multiple organization locations" do
        visit new_sessions_deliveries_path
        expect(page).to have_content("Please choose a pick up or delivery date")

        delivery = Dom::Buying::DeliveryChoice.first
        expect(delivery.type).to eq("Delivery:")
        expect(delivery.date).to eq("Wednesday October 8, 2014")
        expect(delivery.time_range).to eq("Between 12:00PM and 3:00PM")
        expect(delivery).to have_location_select

        delivery.choose!

        expect(page).to have_content(org1_product.name)
      end

      scenario "selecting a direct to buyer delivery with one organization location" do
        while buyer_org.locations.size > 1
          buyer_org.locations.last.destroy
          buyer_org.locations(true)
        end

        visit new_sessions_deliveries_path
        expect(page).to have_content("Please choose a pick up or delivery date")

        delivery = Dom::Buying::DeliveryChoice.first
        expect(delivery.type).to eq("Delivery:")
        expect(delivery.date).to eq("Wednesday October 8, 2014")
        expect(delivery.time_range).to eq("Between 12:00PM and 3:00PM")
        expect(delivery).to_not have_location_select
        expect(delivery.street_address).to eq(buyer_org.locations.first.address)
        expect(delivery.locality).to eq("Ann Arbor")
        expect(delivery.region).to eq("MI")
        expect(delivery.postal_code).to eq("48109")

        delivery.choose!

        expect(page).to have_content(org1_product.name)
      end

      context "belonging to multiple organizations" do
        let!(:buyer_org2)               { create(:organization, :buyer, :single_location, users: [user], markets: [market]) }
        let!(:buyer_org_outside_market) { create(:organization, :buyer, users: [user]) }

        before(:each) do
          visit products_path
        end

        scenario "selecting an organization to shop for" do
          find('#org_id_chosen').click
          list = find('ul.chosen-results')
          expect(list).to have_css('li', text: buyer_org.name)
          expect(list).to have_css('li', text: buyer_org2.name)
          expect(list).to_not have_css('li', text: buyer_org_outside_market.name)
          list.find('li.active-result', text: buyer_org.name).click

          click_button "Select Buyer"

          expect(page).to have_content("Please choose a pick up or delivery date")

          delivery = Dom::Buying::DeliveryChoice.first
          expect(delivery.type).to eq("Delivery:")
          expect(delivery.date).to eq("Wednesday October 8, 2014")
          expect(delivery.time_range).to eq("Between 12:00PM and 3:00PM")
          expect(delivery).to have_location_select

          delivery.choose!

          expect(page).to have_content(buyer_org.name)
          expect(page).to have_content(org1_product.name)
        end

        scenario "changing organization to shop for after creating a cart" do
          select_option_on_singleselect('#org_id_chosen', buyer_org.name)
          click_button "Select Buyer"

          expect(page).to have_content('Please choose a pick up or delivery date')

          delivery = Dom::Buying::DeliveryChoice.first
          expect(delivery.type).to eq("Delivery:")
          expect(delivery.date).to eq("Wednesday October 8, 2014")
          expect(delivery.time_range).to eq("Between 12:00PM and 3:00PM")
          expect(delivery).to have_location_select

          delivery.choose!

          expect(page).to have_content(org1_product.name)

          within(".order-information-container") do
            click_link "Change delivery options"
          end

          select_option_on_singleselect('#org_id_chosen',
                                        buyer_org2.name)
          click_button "Select Buyer"

          expect(page).to have_content("Please choose a pick up or delivery date")

          delivery = Dom::Buying::DeliveryChoice.first
          expect(delivery.type).to eq("Delivery:")
          expect(delivery.date).to eq("Wednesday October 8, 2014")
          expect(delivery.time_range).to eq("Between 12:00PM and 3:00PM")

          delivery.choose!

          expect(page).to have_content(org1_product.name)
        end

      end
    end
  end

  scenario "trying to shop without an address" do
    buyer_org.locations.destroy_all

    ds = create(:delivery_schedule,
                day: 2,
                order_cutoff: 24,
                seller_fulfillment_location_id: 0,
                seller_delivery_start: "7:00 AM",
                seller_delivery_end:  "11:00 AM",
                market: market
    )

    create(:delivery, delivery_schedule: ds)

    visit products_path

    expect(page).to have_content("You must enter an address for this organization before you can shop")
    expect(page).to have_content("Create new address")
  end

  context "organization specific pricing" do
    let!(:everyone_price_1) { org1_product.prices.first.update(sale_price: 10.00) }
    let!(:everyone_price_2) { create(:price, :past_price, product: org1_product, sale_price: 8.00, min_quantity: 5) }
    let!(:org_price_1)      { create(:price, :past_price, product: org1_product, organization: buyer_org, sale_price: 5.00, min_quantity: 5) }

    scenario "organization only sees pricing relavent to them" do
      go_to_order_page

      product = Dom::ProductListing.find_by_name(org1_product.name)
      expect(product.node).to have_content("$10.00")
      expect(product.node).to have_content("$5.00")
      expect(product.node).to_not have_content("$8.00")
    end
  end

  scenario "visiting the shop page after deleting your location" do
    delivery_schedule1.seller_fulfillment_location_id = 0
    delivery_schedule1.save!

    go_to_order_page

    products = Dom::ProductListing.all
    expect(products).to have(2).products

    buyer_org.locations.each(&:soft_delete)

    click_link "Dashboard", match: :first
    click_link "Order", match: :first

    expect(page).to have_content("You must enter an address for this organization before you can shop")

    fill_in "Address Label", with: "Warehouse 1"
    fill_in "Address", with: "1021 Burton St."
    fill_in "City", with: "Orleans Twp."
    select "Michigan", from: "State"
    fill_in "Postal Code", with: "49883"
    fill_in "Phone", with: "616-555-9983"
    fill_in "Fax", with: "616-555-9984"

    click_button "Add Address"

    go_to_order_page

    products = Dom::ProductListing.all
    expect(products).to have(2).products
  end

  scenario "visiting the shop page after deleting your delivery schedule" do
    within(".order-information-container") do
      expect(page).to have_content("Oct. 10, 2014")
    end

    delivery_schedule1.soft_delete
    delivery_schedule4.update_attribute(:inactive_at, nil)

    click_link "Dashboard", match: :first
    click_link "Order", match: :first

    within(".order-information-container") do
      expect(page).to have_content("Oct. 8, 2014")
    end
  end

  scenario "delivery schedule info shows correctly for delivery products" do
    delivery_schedule1.update_attribute(:seller_fulfillment_location_id, 0)
    go_to_order_page

    within(".order-information-container") do
      expect(page).to have_content("Delivery date: Friday, Oct. 10, 2014")
    end
  end
end
