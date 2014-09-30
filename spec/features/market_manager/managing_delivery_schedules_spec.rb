require "spec_helper"

describe "Market Manager managing delivery schedules" do
  let!(:user)         { create(:user, :market_manager) }
  let!(:market)       { user.managed_markets.first }
  let!(:address)      { create(:market_address, market: market) }
  let!(:organization) { create(:organization, :seller, markets: [market]) }
  let!(:all_deliveries_product)    { create(:product, :sellable, organization: organization) }
  let!(:select_deliveries_product) { create(:product, :sellable, organization: organization, use_all_deliveries: false) }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as user
    visit "/admin/markets"
    click_link market.name
  end

  it "adding a new schedule" do
    expect(all_deliveries_product.reload.delivery_schedules.count).to eql(0)
    expect(select_deliveries_product.reload.delivery_schedules.count).to eql(0)

    click_link "Deliveries"
    click_link "Add Delivery"

    select "Tuesday", from: "Day"
    fill_in "Order cutoff", with: "6"
    select "Direct to customer", from: "Fulfillment method"
    select "Tuesday", from: "Seller delivery day"
    select "7:15 AM", from: "Seller delivery start"
    select "11:30 AM", from: "Seller delivery end"

    click_button "Save Delivery"

    expect(page).to have_content("Saved delivery schedule")
    expect(all_deliveries_product.reload.delivery_schedules.count).to eql(1)
    expect(select_deliveries_product.reload.delivery_schedules.count).to eql(0)

    s = all_deliveries_product.delivery_schedules.first
    expect(s.buyer_day).to eq(2)
    expect(s.buyer_pickup_start).to eq("12:00 AM")
    expect(s.buyer_pickup_end).to eq("12:00 AM")
    expect(s.day).to eq(2)
    expect(s.seller_delivery_start).to eq("7:15 AM")
    expect(s.seller_delivery_end).to eq("11:30 AM")
  end

  it "adding a new schedule with market fulfillment", js: true do
    click_link "Deliveries"
    click_link "Add Delivery"

    expect(page).to_not have_content("Buyer pickup start")
    expect(page).to_not have_content("Market will pick up from seller location")

    select "Tuesday", from: "Day"
    fill_in "Order cutoff", with: "6"
    select address.name, from: "Fulfillment method"
    select "Monday", from: "Seller delivery day"
    select "8:00 PM", from: "Seller delivery start"
    select "10:00 PM", from: "Seller delivery end"

    expect(page).to have_content("Buyer pick up/delivery start")
    expect(page).to have_content("Market will pick up from seller location")

    select "11:00 AM", from: "Buyer pick up/delivery start"
    select "2:00 PM", from: "Buyer pick up/delivery end"

    click_button "Save Delivery"

    expect(page).to have_content("Saved delivery schedule")

    expect(market.delivery_schedules.count).to eq(1)
    delivery = market.delivery_schedules.first

    delivery_schedules = Dom::Admin::DeliverySchedule.all
    sched = delivery_schedules.first
    expect(sched.weekday).to eq("Tuesday")
    expect(sched.cutoff).to match(/ #{delivery.order_cutoff} /)
    expect(sched.delivery_address).to include("#{address.address}, #{address.city}, #{address.state} #{address.zip}")
    expect(sched.delivery_time).to include("Monday")
    expect(sched.delivery_time).to include("#{delivery.seller_delivery_start} – #{delivery.seller_delivery_end}")
    expect(sched.pickup_time).to include("Tuesday")
    expect(sched.pickup_time).to include("#{delivery.buyer_pickup_start} – #{delivery.buyer_pickup_end}")
  end

  scenario "deleted addresses do not show" do
    click_link "Address"
    expect(page).to have_content("44 E. 8th St, Holland, MI 49423")

    market.addresses[0].update_attributes(deleted_at: 1.day.ago)
    visit current_path
    expect(page).not_to have_content("44 E. 8th St, Holland, MI 49423")
  end

  context "list" do
    let!(:delivery1) { create(:delivery_schedule, market: market) }
    let!(:delivery2) { create(:delivery_schedule, 
                              order_cutoff: 12, 
                              seller_fulfillment_location: address, 
                              market: market, 
                              buyer_pickup_location_id: 0, 
                              day: 4,
                              seller_delivery_start: "8:00 AM", 
                              seller_delivery_end: "11:00 AM",
                              buyer_day: 5, 
                              buyer_pickup_start: "1:00 PM", 
                              buyer_pickup_end: "4:00 PM"
                             ) 
                     }

    it "shows a list of delivery schedules" do
      click_link "Deliveries"

      delivery_schedules = Dom::Admin::DeliverySchedule.all

      expect(delivery_schedules.size).to eq(2)

      first_schedule = delivery_schedules.first
      expect(first_schedule.weekday).to eq("Tuesday")
      expect(first_schedule.cutoff).to match(/ #{delivery1.order_cutoff} /)
      expect(first_schedule.delivery_address).to match(/Direct to customer/)
      expect(first_schedule.delivery_time).to include("Tuesday")
      expect(first_schedule.delivery_time).to include("#{delivery1.seller_delivery_start} – #{delivery1.seller_delivery_end}")
      expect(first_schedule.pickup_time).to be_blank

      last_schedule = delivery_schedules.last
      expect(last_schedule.weekday).to eq("Friday")
      expect(last_schedule.cutoff).to match(/ #{delivery2.order_cutoff} /)
      expect(last_schedule.delivery_address).to include("#{address.address}, #{address.city}, #{address.state} #{address.zip}")
      expect(last_schedule.delivery_time).to include("Thursday")
      expect(last_schedule.delivery_time).to include("#{delivery2.seller_delivery_start} – #{delivery2.seller_delivery_end}")
      expect(last_schedule.pickup_time).to include("Friday")
      expect(last_schedule.pickup_time).to include("#{delivery2.buyer_pickup_start} – #{delivery2.buyer_pickup_end}")
    end

    it "edits a delivery schedule" do
      click_link "Deliveries"

      click_link delivery1.weekday

      select "3:00 AM", from: "Seller delivery start"

      click_button "Save Delivery"

      expect(page.body).to have_content("Saved delivery schedule");

      schedule = Dom::Admin::DeliverySchedule.first
      expect(schedule.delivery_time).to include("3:00 AM – #{delivery1.seller_delivery_end}")
    end

    it "edits a delivery schedule's fulfillment method" do
      click_link "Deliveries"

      schedule = Dom::Admin::DeliverySchedule.first
      expect(schedule.delivery_address).to have_content("Direct to customer")

      click_link delivery1.weekday
      select address.name, from: "Fulfillment method"
      select "3:00 AM", from: "Seller delivery start"
      select "4:00 AM", from: "Seller delivery end"
      select "6:00 AM", from: "Buyer pick up/delivery start"
      select "7:00 AM", from: "Buyer pick up/delivery end"

      click_button "Save Delivery"

      expect(page.body).to have_content("Saved delivery schedule");
      schedule = Dom::Admin::DeliverySchedule.first
      expect(schedule.delivery_address).not_to have_content("Direct to customer")

      delivery1.reload
      schedule = Dom::Admin::DeliverySchedule.first
      expect(schedule.delivery_time).to include("3:00 AM – #{delivery1.seller_delivery_end}")
    end

    it "deletes a delivery schedule" do
      click_link "Deliveries"

      schedule = Dom::Admin::DeliverySchedule.first
      schedule.click_delete

      expect(page).to have_content("Deleted delivery schedule.")
      expect(page).to_not have_content(delivery1.weekday)
    end
  end
end
