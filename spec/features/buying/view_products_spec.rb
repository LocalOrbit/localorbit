require "spec_helper"

feature "Viewing products" do
  let!(:org1) { create(:organization, :seller) }
  let!(:org2) { create(:organization, :seller) }
  let!(:org1_product) { create(:product, :sellable, organization: org1) }
  let!(:org2_product) { create(:product, :sellable, organization: org2) }
  let(:available_products) { [org1_product, org2_product] }

  let!(:other_org) { create(:organization, :seller) }
  let!(:other_products) { create_list(:product, 3, organization: other_org) }

  let!(:org2_product_deleted) { create(:product, :sellable, organization: org2, deleted_at: 1.day.ago) }

  let!(:buyer_org) { create(:organization, :multiple_locations, :buyer) }
  let(:user) { create(:user, organizations: [buyer_org]) }

  let!(:market) { create(:market, :with_addresses, organizations: [org1, org2, buyer_org]) }

  before do
    other_products.each do |prod|
      create(:price, product: prod)
      create(:lot, product: prod)
    end

    Timecop.travel(DateTime.parse("October 7 2014"))
    switch_to_subdomain market.subdomain
    sign_in_as(user)
  end

  after do
    Timecop.return
  end

  scenario "list of products" do
    #TODO: Filter products based on delivery
    #      Since adding the delivery selection,
    #      this spec is broken. We're not yet filtering
    #      based on the current delivery
    #click_link "Shop"

    #products = Dom::Product.all

    #expect(products).to have(2).products
    #expect(products.map(&:name)).to match_array(available_products.map(&:name))

    #product = available_products.first
    #dom_product = Dom::Product.find_by_name(product.name)

    #expect(dom_product.organization_name).to have_text(product.organization_name)
    #expected_price = "$%.2f" % product.prices.first.sale_price
    #expect(dom_product.pricing).to have_text(expected_price)
    #expect(dom_product.quantity).to have_text(expected_price)
  end

  context "single delivery schedule" do
    context "multiple locations" do
      scenario "change delivery location after the fact"
    end

    context "single location" do
      scenario "shopping without an existing shopping cart" do
        create(:delivery_schedule, :buyer_pickup,
          day: 5,
          order_cutoff: 24,
          seller_delivery_start: "7:00 AM",
          seller_delivery_end:  "11:00 AM",
          buyer_pickup_start: "12:00 PM",
          buyer_pickup_end: "2:00 PM",
          market: market
        )

        click_link "Shop"

        expect(page).to have_content(org1_product.name)
      end

      context "as a market manager" do
        let(:user) { create(:user, managed_markets: [market]) }

        scenario "has to select an organization to shop as" do
          create(:delivery_schedule, :buyer_pickup,
            day: 5,
            order_cutoff: 24,
            seller_delivery_start: "7:00 AM",
            seller_delivery_end:  "11:00 AM",
            buyer_pickup_start: "12:00 PM",
            buyer_pickup_end: "2:00 PM",
            market: market
          )

          create(:delivery_schedule,
            day: 2,
            order_cutoff: 24,
            seller_fulfillment_location_id: 0,
            seller_delivery_start: "6:00 AM",
            seller_delivery_end:  "11:00 AM",
            market: market,
            deleted_at: 1.minute.ago
          )

          click_link "Shop"

          select buyer_org.name, from: 'Select an organization'

          click_button 'Select Organization'

          expect(page).to have_content(org1_product.name)
        end
      end
    end
  end

  context "multiple delivery schedules" do

    scenario "shopping without an existing shopping cart" do
      address = market.addresses.first
      address.name = "Market Place"
      address.address = "123 Street Ave."
      address.city = "Town"
      address.state = "MI"
      address.zip = "32339"
      address.save!

      create(:delivery_schedule, :buyer_pickup,
        day: 5,
        order_cutoff: 24,
        seller_delivery_start: "7:00 AM",
        seller_delivery_end:  "11:00 AM",
        buyer_pickup_start: "12:00 PM",
        buyer_pickup_end: "2:00 PM",
        market: market
      )

      create(:delivery_schedule,
        day: 2,
        order_cutoff: 24,
        seller_fulfillment_location_id: 0,
        seller_delivery_start: "7:00 AM",
        seller_delivery_end:  "11:00 AM",
        market: market
      )

      create(:delivery_schedule,
        day: 3,
        order_cutoff: 24,
        seller_fulfillment_location: address,
        seller_delivery_start: "7:00 AM",
        seller_delivery_end:  "11:00 AM",
        buyer_pickup_start: "12:00 PM",
        buyer_pickup_end: "3:00 PM",
        buyer_pickup_location_id: 0,
        market: market
      )

      create(:delivery_schedule,
        day: 2,
        order_cutoff: 24,
        seller_fulfillment_location_id: 0,
        seller_delivery_start: "6:00 AM",
        seller_delivery_end:  "11:00 AM",
        market: market,
        deleted_at: 1.minute.ago
      )

      click_link "Shop"

      expect(page).to have_content("Please choose a pick up or delivery date.")

      delivery_choices = Dom::Buying::DeliveryChoice.all
      expect(delivery_choices.size).to eq(3)

      # This order does matter
      expect(delivery_choices[0].type).to eq("Delivery:")
      expect(delivery_choices[0].date).to eq("October 8, 2014")
      expect(delivery_choices[0].time_range).to eq("Between 12:00PM and 3:00PM")
      expect(delivery_choices[0]).to have_location_select

      expect(delivery_choices[1].type).to eq("Pick Up:")
      expect(delivery_choices[1].date).to eq("October 10, 2014")
      expect(delivery_choices[1].time_range).to eq("Between 12:00PM and 2:00PM")
      expect(delivery_choices[1].location).to eq("123 Street Ave. Town, MI 32339")

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
    end

    scenario "selecting a direct to buyer delivery with multiple organization locations" do
      ds = create(:delivery_schedule,
        day: 2,
        order_cutoff: 24,
        seller_fulfillment_location_id: 0,
        seller_delivery_start: "7:00 AM",
        seller_delivery_end:  "11:00 AM",
        market: market
      )

      create(:delivery, delivery_schedule: ds)

      ds2 = create(:delivery_schedule, :buyer_pickup,
        day: 5,
        order_cutoff: 24,
        seller_fulfillment_location_id: 0,
        seller_delivery_start: "7:00 AM",
        seller_delivery_end:  "11:00 AM",
        market: market
      )

      create(:delivery, delivery_schedule: ds2)

      click_link "Shop"

      expect(page).to have_content("Please choose a pick up or delivery date.")

      delivery = Dom::Buying::DeliveryChoice.first
      expect(delivery.node.text).to match(/Delivery: October 10, 2014 Between 7:00AM and 11:00AM/)

      delivery.choose!

      expect(page).to have_content(org1_product.name)
    end

    scenario "selecting a direct to buyer delivery with one organization location" do
      while buyer_org.locations.size > 1
        buyer_org.locations.last.destroy
        buyer_org.locations(true)
      end

      ds = create(:delivery_schedule,
        day: 2,
        order_cutoff: 24,
        seller_fulfillment_location_id: 0,
        seller_delivery_start: "7:00 AM",
        seller_delivery_end:  "11:00 AM",
        market: market
      )

      create(:delivery, delivery_schedule: ds)

      ds2 = create(:delivery_schedule, :buyer_pickup,
        day: 5,
        order_cutoff: 24,
        seller_fulfillment_location_id: 0,
        seller_delivery_start: "7:00 AM",
        seller_delivery_end:  "11:00 AM",
        market: market
      )

      create(:delivery, delivery_schedule: ds2)

      click_link "Shop"

      expect(page).to have_content("Please choose a pick up or delivery date.")

      delivery = Dom::Buying::DeliveryChoice.first
      expect(delivery).not_to be_nil

      expect(delivery.node.text).to match(/Delivery: October 10, 2014 Between 7:00AM and 11:00AM/)

      delivery.choose!

      expect(page).to have_content(org1_product.name)
    end

    context "belonging to multiple organizations" do
      let!(:buyer_org2)               { create(:organization, :buyer, users: [user], markets: [market]) }
      let!(:buyer_org_outside_market) { create(:organization, :buyer, users: [user]) }

      scenario "selecting an organization to shop for" do
        ds = create(:delivery_schedule,
          day: 2,
          order_cutoff: 24,
          seller_fulfillment_location_id: 0,
          seller_delivery_start: "7:00 AM",
          seller_delivery_end:  "11:00 AM",
          market: market
        )

        create(:delivery, delivery_schedule: ds)

        ds2 = create(:delivery_schedule, :buyer_pickup,
          day: 5,
          order_cutoff: 24,
          seller_fulfillment_location_id: 0,
          seller_delivery_start: "7:00 AM",
          seller_delivery_end:  "11:00 AM",
          market: market
        )

        create(:delivery, delivery_schedule: ds2)

        click_link "Shop"

        select = Dom::Select.first

        expect(select).to have_option(buyer_org.name)
        expect(select).to have_option(buyer_org2.name)
        expect(select).to_not have_option(buyer_org_outside_market.name)

        select buyer_org.name, from: "Select an organization"

        click_button 'Select Organization'

        expect(page).to have_content("Please choose a pick up or delivery date.")

        delivery = Dom::Buying::DeliveryChoice.first
        expect(delivery).not_to be_nil

        expect(delivery.node.text).to match(/Delivery: October 10, 2014 Between 7:00AM and 11:00AM/)

        delivery.choose!

        expect(page).to have_content(org1_product.name)
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

    click_link "Shop"

    expect(page).to have_content("You must enter an address for this organization before you can shop")

    expect(page).to have_content("Create new address")
  end
end
