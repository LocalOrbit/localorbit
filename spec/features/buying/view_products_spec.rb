require "spec_helper"

feature "Viewing products" do
  let!(:market) { create(:market, :with_addresses) }
  let!(:delivery_schedule1) { create(:delivery_schedule, :buyer_pickup, market: market, day: 5, order_cutoff: 24, buyer_pickup_location_id: 0, buyer_pickup_start: "12:00 PM", buyer_pickup_end: "2:00 PM") }
  let!(:delivery_schedule2) { create(:delivery_schedule, market: market, day: 3, deleted_at: Time.parse('2013-03-21')) }

  let!(:org1) { create(:organization, :seller, markets: [market]) }
  let!(:org1_product) { create(:product, :sellable, name: "celery", organization: org1, delivery_schedules: [delivery_schedule1]) }

  let!(:org2) { create(:organization, :seller, markets: [market]) }
  let!(:org2_product) { create(:product, :sellable, organization: org2, delivery_schedules: [delivery_schedule1]) }
  let!(:org2_product_deleted) { create(:product, :sellable, organization: org2, deleted_at: 1.day.ago) }

  let!(:inactive_org) { create(:organization, :seller, active: false, markets: [market]) }
  let!(:inactive_org_product) { create(:product, :sellable, organization: inactive_org, delivery_schedules: [delivery_schedule1])}

  let!(:other_org) { create(:organization, :seller) }
  let!(:other_products) { create_list(:product, 3, :sellable, organization: other_org) }

  let!(:buyer_org) { create(:organization, :single_location, :buyer, markets: [market]) }
  let(:user) { create(:user, organizations: [buyer_org]) }
  let(:market_manager) { create(:user, managed_markets: [market]) }

  let(:available_products) { [org1_product, org2_product] }

  def celery_item
    Dom::Cart::Item.find_by_name("celery")
  end

  before do
    Timecop.travel(DateTime.parse("October 7 2014"))
    switch_to_subdomain market.subdomain
  end

  after do
    Timecop.return
  end

  scenario "list of products" do
    sign_in_as(user)

    products = Dom::Product.all

    within(".table-summary") do
      expect(page).to have_content("between 12:00PM and 2:00PM")
    end

    expect(products).to have(2).products
    expect(products.map(&:name)).to match_array(available_products.map(&:name))

    product = available_products.first
    dom_product = Dom::Product.find_by_name(product.name)

    expect(dom_product.organization_name).to have_text(product.organization_name)
    expected_price = "$%.2f" % product.prices.first.sale_price
    expect(dom_product.pricing).to have_text(expected_price)
    expect(dom_product.quantity).to have_text(expected_price)
  end

  scenario "list of products after a selling organization is deleted" do
    switch_user(market_manager) do
      delete_organization(org2)
    end

    sign_in_as(user)
    products = Dom::Product.all

    expect(products).to have(1).products
    expect(products.map(&:name)).to match_array([available_products.first.name])

    product = available_products.first
    dom_product = Dom::Product.find_by_name(product.name)

    expect(dom_product.organization_name).to have_text(product.organization_name)
    expected_price = "$%.2f" % product.prices.first.sale_price
    expect(dom_product.pricing).to have_text(expected_price)
    expect(dom_product.quantity).to have_text(expected_price)
  end


  scenario "a product with less inventory than required to purchase" do
    org1_product.prices.first.update(min_quantity: 200) #there are only 150
    org1_product.prices << create(:price, min_quantity: 300) # current scope is summing total available quantity once for each price that exists.
    org1_product.prices << create(:price, market_id: market.id,          min_quantity: 200, sale_price: 2.50)
    org1_product.prices << create(:price, organization_id: buyer_org.id, min_quantity: 200, sale_price: 2.40)
    sign_in_as(user)

    expect(Dom::Product.all.count).to eql(1)
    expect(Dom::Product.find_by_name(org1_product.name)).to be_nil
    expect(Dom::Product.find_by_name(org2_product.name)).to_not be_nil
  end

  scenario "a product with just enough inventory required to purchase" do
    org1_product.prices.first.update(min_quantity: 150) #there are only 150
    org1_product.prices << create(:price, min_quantity: 150) # current scope is summing total available quantity once for each price that exists.
    org1_product.prices << create(:price, market_id: market.id,          min_quantity: 150, sale_price: 2.50)
    org1_product.prices << create(:price, organization_id: buyer_org.id, min_quantity: 150, sale_price: 2.40)
    sign_in_as(user)

    expect(Dom::Product.all.count).to eql(2)
    expect(Dom::Product.find_by_name(org1_product.name)).to_not be_nil
    expect(Dom::Product.find_by_name(org2_product.name)).to_not be_nil
  end

  scenario "a product with less inventory than required to purchase that is cross-sold in multiple markets" do
    delivery_schedule1.require_delivery = true
    delivery_schedule1.save!

    delivery_schedule2.deleted_at = nil
    delivery_schedule2.save!

    org1_product.delivery_schedules << delivery_schedule2
    org1_product.save!

    org2_product.delivery_schedules << delivery_schedule2
    org2_product.save!

    org1_product.prices.first.update(min_quantity: 200) #there are only 150
    org1_product.prices << create(:price, min_quantity: 300) # current scope is summing total available quantity once for each price that exists.
    org1_product.prices << create(:price, market_id: market.id,          min_quantity: 200, sale_price: 2.50)
    org1_product.prices << create(:price, organization_id: buyer_org.id, min_quantity: 200, sale_price: 2.40)
    sign_in_as(user)

    choose_delivery "Between 12:00PM and 2:00PM"

    expect(Dom::Product.all.count).to eql(1)
    expect(Dom::Product.find_by_name(org1_product.name)).to be_nil
    expect(Dom::Product.find_by_name(org2_product.name)).to_not be_nil
  end

  scenario "a product with inventory that expires before the delivery" do
    org1_product.lots.first.update(number: "1", expires_at: DateTime.parse("October 8, 2014 00:00"))
    sign_in_as(user)

    expect(Dom::Product.all.count).to eql(1)
    expect(Dom::Product.find_by_name(org1_product.name)).to be_nil
    expect(Dom::Product.find_by_name(org2_product.name)).to_not be_nil
  end

  scenario "an individual product" do
    sign_in_as(user)
    product = available_products.first
    click_link product.name
    expect(page).to have_text(product.name)
  end

  scenario "changing the quantity for a listed product", js: true do
    create(:price, product: org1_product, sale_price: 1.50, min_quantity: 5)

    sign_in_as(user)

    # See prices for the item
    expect(celery_item.unit_prices.count).to eql(2)
    expect(celery_item.unit_prices).to include("$3.00")
    expect(celery_item.unit_prices).to include("$1.50")

    # See the initial totals
    expect(celery_item.price_for_quantity).to have_content("$3.00")
    expect(celery_item.node.find(".total")).to have_content("$0.00")

    # See updated
    celery_item.set_quantity(5)
    celery_item.price.click
    expect(Dom::CartLink.first).to have_content("Added to cart!")

    # Ensure the totals update when the products update
    expect(celery_item.price_for_quantity).to have_content("$1.50")
    expect(celery_item.node.find(".total")).to have_content("$7.50")
  end

  context "pick up or delivery date" do
    let!(:delivery_schedule) { create(:delivery_schedule, market: market, day: 3, seller_delivery_start: "4:00 PM", seller_delivery_end: "8:00 PM") }

    before do
      delivery_schedule1.update_column(:buyer_pickup_location_id, market.addresses.first.id)
      org1_product.delivery_schedules << delivery_schedule
      sign_in_as(user)
    end

    it "displays selected pick up date and location" do
      Dom::Buying::DeliveryChoice.all.last.choose!

      selected_delivery = Dom::Buying::SelectedDelivery.first
      location = market.addresses.first

      expect(selected_delivery.delivery_type).to eq("Pick Up Date")
      expect(selected_delivery.display_date).to eq("October 10, 2014")
      expect(selected_delivery.time_range).to eq("between 12:00PM and 2:00PM")
      expect(selected_delivery.location_name).to eq(location.name)
      expect(selected_delivery.location_address).to eq("#{location.address} #{location.city}, #{location.state} #{location.zip}")
    end

    it "displays selected delivery date and location" do
      Dom::Buying::DeliveryChoice.first.choose!

      selected_delivery = Dom::Buying::SelectedDelivery.first
      location = buyer_org.locations.first

      expect(selected_delivery.delivery_type).to eq("Delivery Date")
      expect(selected_delivery.display_date).to eq("October 8, 2014")
      expect(selected_delivery.time_range).to eq("between 4:00PM and 8:00PM")
      expect(selected_delivery.location_name).to eq(location.name)
      expect(selected_delivery.location_address).to eq("#{location.address} #{location.city}, #{location.state} #{location.zip}")
    end

    context "when changing selected delivery", js: true do
      it "allows user to change" do
        Dom::Buying::DeliveryChoice.all.last.choose!

        selected_delivery = Dom::Buying::SelectedDelivery.first
        expect(selected_delivery.delivery_type).to eq("Pick Up Date")
        expect(selected_delivery.display_date).to eq("October 10, 2014")
        expect(selected_delivery.time_range).to eq("between 12:00PM and 2:00PM")

        Dom::Buying::SelectedDelivery.first.click_change

        expect(page).to have_content("Please choose a pick up or delivery date")
        Dom::Buying::DeliveryChoice.first.choose!

        selected_delivery = Dom::Buying::SelectedDelivery.first
        expect(selected_delivery.delivery_type).to eq("Delivery Date")
        expect(selected_delivery.display_date).to eq("October 8, 2014")
        expect(selected_delivery.time_range).to eq("between 4:00PM and 8:00PM")
      end

      it "warns user if cart has any items", js: true do
        Dom::Buying::DeliveryChoice.first.choose!

        product = Dom::Cart::Item.find_by_name("celery")
        product.set_quantity(3)
        product.price.click
        expect(Dom::CartLink.first.count).to have_content("1")

        Dom::Buying::SelectedDelivery.first.click_change
        expect(page).to have_content("Date Change Confirmation")
        click_link("Empty Cart and Change Date")

        Dom::Buying::DeliveryChoice.all.last.choose!
        expect(Dom::CartLink.first.count).to have_content("0")

        Dom::Buying::SelectedDelivery.first.click_change
        expect(page).not_to have_content("Date Change Confirmation")

        Dom::Buying::DeliveryChoice.first.choose!
        expect(Dom::CartLink.first.count).to have_content("0")
      end
    end
  end

  context "single delivery schedule" do
    context "as a buyer" do
      before do
        sign_in_as(user)
      end

      context "multiple locations" do
        let!(:second_location) { create(:location, organization: buyer_org) }

        scenario "shows the 'change' link" do
          visit products_path
          within('.selected-delivery') do
            expect(page).to have_link('Change')
          end
        end

        scenario "change delivery location after the fact"
      end

      context "single location" do
        scenario "shopping without an existing shopping cart" do
          expect(page).to have_content(org1_product.name)
        end

        scenario "does not show the 'change' link" do
          within('.selected-delivery') do
            expect(page).to_not have_link('Change')
          end
        end
      end

      context "user is a member of multiple organizations" do
        let!(:buyer_org2) { create(:organization, :single_location, :buyer, markets: [market], users: [user]) }

        scenario "shows the 'change' link" do
          visit products_path

          select buyer_org.name, from: 'Organization'

          click_button 'Select Organization'

          within('.selected-delivery') do
            expect(page).to have_link('Change')
          end
        end
      end
    end

    context "as a market manager" do
      let(:user) { create(:user, managed_markets: [market]) }
      before do
        sign_in_as(user)
      end

      scenario "has to select an organization to shop as" do
        click_link "Shop", match: :first

        select buyer_org.name, from: 'Organization'

        click_button 'Select Organization'

        expect(page).to have_content(org1_product.name)
      end
    end
  end

  context "multiple delivery schedules" do
    let!(:second_location) { create(:location, organization: buyer_org) }

    let!(:ds3) { create(:delivery_schedule,
      day: 2,
      order_cutoff: 24,
      seller_fulfillment_location_id: 0,
      seller_delivery_start: "7:00 AM",
      seller_delivery_end:  "11:00 AM",
      market: market
    ) }

    let!(:ds4) { create(:delivery_schedule,
      day: 3,
      order_cutoff: 24,
      seller_fulfillment_location: market.addresses.first,
      seller_delivery_start: "7:00 AM",
      seller_delivery_end:  "11:00 AM",
      buyer_pickup_start: "12:00 PM",
      buyer_pickup_end: "3:00 PM",
      buyer_pickup_location_id: 0,
      market: market
    ) }

    let!(:ds3_product) { create(:product, :sellable, organization: org1, use_all_deliveries: false, delivery_schedules: [ds3]) }

    before do
      org1_product.delivery_schedules << ds4
    end

    scenario "shopping without an existing shopping cart" do
      delivery_schedule1.update_column(:buyer_pickup_location_id, market.addresses.first.id)

      address = market.addresses.first
      address.name = "Market Place"
      address.address = "123 Street Ave."
      address.city = "Town"
      address.state = "MI"
      address.zip = "32339"
      address.save!

      sign_in_as(user)

      expect(page).to have_content("Please choose a pick up or delivery date.")

      delivery_choices = Dom::Buying::DeliveryChoice.all
      expect(delivery_choices.size).to eq(3)

      # This order does matter
      expect(delivery_choices[0].type).to eq("Delivery:")
      expect(delivery_choices[0].date).to eq("October 8, 2014")
      expect(delivery_choices[0].time_range).to eq("Between 12:00PM and 3:00PM")
      expect(delivery_choices[0]).to have_location_select

      expect(delivery_choices[1].type).to eq("Pick up:")
      expect(delivery_choices[1].date).to eq("October 10, 2014")
      expect(delivery_choices[1].time_range).to eq("Between 12:00PM and 2:00PM")
      expect(delivery_choices[1].street_address).to eq("123 Street Ave.")
      expect(delivery_choices[1].locality).to eq("Town")
      expect(delivery_choices[1].region).to eq("MI")
      expect(delivery_choices[1].postal_code).to eq("32339")

      expect(delivery_choices[2].type).to eq("Delivery:")
      expect(delivery_choices[2].date).to eq("October 14, 2014")
      expect(delivery_choices[2].time_range).to eq("Between 7:00AM and 11:00AM")
      expect(delivery_choices[2]).to have_location_select

      click_button "Start Shopping"
      within('.flash--alert') do
        expect(page).to have_content("Please select a delivery")
      end

      delivery = Dom::Buying::DeliveryChoice.first
      delivery.choose!

      expect(page).to have_content(org1_product.name)
      expect(page).to_not have_content(ds3_product.name)
    end

    context "direct to buyer" do
      scenario "selecting a direct to buyer delivery with multiple organization locations" do
        sign_in_as(user)

        expect(page).to have_content("Please choose a pick up or delivery date.")

        delivery = Dom::Buying::DeliveryChoice.first
        expect(delivery.type).to eq("Delivery:")
        expect(delivery.date).to eq("October 8, 2014")
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

        sign_in_as(user)

        expect(page).to have_content("Please choose a pick up or delivery date.")

        delivery = Dom::Buying::DeliveryChoice.first
        expect(delivery.type).to eq("Delivery:")
        expect(delivery.date).to eq("October 8, 2014")
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
          sign_in_as(user)
        end

        scenario "selecting an organization to shop for" do
          select = Dom::Select.first

          expect(select).to have_option(buyer_org.name)
          expect(select).to have_option(buyer_org2.name)
          expect(select).to_not have_option(buyer_org_outside_market.name)

          select buyer_org.name, from: "Organization"

          click_button 'Select Organization'

          expect(page).to have_content("Please choose a pick up or delivery date.")

          delivery = Dom::Buying::DeliveryChoice.first
          expect(delivery.type).to eq("Delivery:")
          expect(delivery.date).to eq("October 8, 2014")
          expect(delivery.time_range).to eq("Between 12:00PM and 3:00PM")
          expect(delivery).to have_location_select

          delivery.choose!

          expect(page).to have_content(buyer_org.name)
          expect(page).to have_content(org1_product.name)
        end

        scenario "changing organization to shop for after creating a cart", js:true  do
          select = Dom::Select.first

          expect(select).to have_option(buyer_org.name)
          expect(select).to have_option(buyer_org2.name)
          expect(select).to_not have_option(buyer_org_outside_market.name)

          select buyer_org.name, from: "Organization"

          click_button 'Select Organization'

          expect(page).to have_content("Please choose a pick up or delivery date.")

          delivery = Dom::Buying::DeliveryChoice.first
          expect(delivery.type).to eq("Delivery:")
          expect(delivery.date).to eq("October 8, 2014")
          expect(delivery.time_range).to eq("Between 12:00PM and 3:00PM")
          expect(delivery).to have_location_select

          delivery.choose!

          expect(page).to have_content(org1_product.name)

          within ".change-delivery" do
            click_link "Change"
          end

          select buyer_org2.name, from: "Organization"

          click_button 'Select Organization'

          expect(page).to have_content("Please choose a pick up or delivery date.")

          delivery = Dom::Buying::DeliveryChoice.first
          expect(delivery.type).to eq("Delivery:")
          expect(delivery.date).to eq("October 8, 2014")
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

    sign_in_as(user)

    expect(page).to have_content("You must enter an address for this organization before you can shop")

    expect(page).to have_content("Create new address")
  end

  context "organization specific pricing" do
    let!(:everyone_price_1) { org1_product.prices.first.update(sale_price: 10.00) }
    let!(:everyone_price_2) { create(:price, product: org1_product, sale_price: 8.00, min_quantity: 5) }
    let!(:org_price_1)      { create(:price, product: org1_product, organization: buyer_org, sale_price: 5.00, min_quantity: 5) }

    scenario "organization only sees pricing relavent to them" do
      sign_in_as(user)

      product = Dom::Product.find_by_name(org1_product.name)
      expect(product.prices).to include("$10.00", "$5.00")
      expect(product.prices).to_not include("$8.00")
    end
  end

  scenario "visiting the shop page after deleting your location" do
    delivery_schedule1.seller_fulfillment_location_id = 0
    delivery_schedule1.save!

    sign_in_as(user)

    products = Dom::Product.all
    expect(products).to have(2).products

    buyer_org.locations.each(&:soft_delete)

    click_link "Dashboard", match: :first
    click_link "Shop", match: :first

    expect(page).to have_content("You must enter an address for this organization before you can shop")

    fill_in "Address Label", with: "Warehouse 1"
    fill_in "Address", with: "1021 Burton St."
    fill_in "City", with: "Orleans Twp."
    select "Michigan", from: "State"
    fill_in "Postal Code", with: "49883"
    fill_in "Phone", with: "616-555-9983"
    fill_in "Fax", with: "616-555-9984"

    click_button "Add Address"

    click_link "Shop", match: :first

    products = Dom::Product.all
    expect(products).to have(2).products
  end

  scenario "visiting the shop page after deleting your delivery schedule" do
    sign_in_as(user)

    within('.selected-delivery') do
      expect(page).to have_content("October 10, 2014")
    end

    delivery_schedule1.soft_delete
    delivery_schedule2.update_attribute(:deleted_at, nil)

    click_link "Dashboard", match: :first
    click_link "Shop", match: :first

    within('.selected-delivery') do
      expect(page).to have_content("October 8, 2014")
    end
  end

  scenario "delivery schedule info shows correctly for delivery products" do
    delivery_schedule1.update_attribute(:seller_fulfillment_location_id, 0)
    sign_in_as(user)

    within(".table-summary") do
      expect(page).to have_content("Delivery date is October 10, 2014")
    end
  end

  scenario "delivery schedule info shows correctly for pick up products" do
    delivery_schedule1.update_column(:buyer_pickup_location_id, market.addresses.first.id)
    
    sign_in_as(user)

    within(".table-summary") do
      expect(page).to have_content("Pick up date is October 10, 2014")
    end
  end
end
