require "spec_helper"

describe "Pick list" do
  let!(:market)  { create(:market) }
  let!(:sellers) { create(:organization, :seller, :single_location, markets: [market]) }
  let!(:product1) { create(:product, :sellable, organization: sellers) }

  let!(:friday_schedule_schedule) { create(:delivery_schedule, market: market, day: 5) }
  let!(:friday_delivery) { create(:delivery, delivery_schedule: friday_schedule_schedule, deliver_on: Date.parse("May 9, 2014"), cutoff_time: Date.parse("May 8, 2014"))}

  let!(:buyer1) { create(:organization, :buyer, :single_location, markets: [market]) }
  let!(:buyer2) { create(:organization, :buyer, :single_location, markets: [market]) }

  let(:user)     { create(:user, organizations: [sellers]) }

  before do
    Timecop.travel("May 5, 2014")
  end

  after do
    Timecop.return
  end

  context "before the delivery cutoff" do
    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
      visit admin_delivery_tools_pick_list_path(friday_delivery.id)
    end

    it "shows the pick list" do
      expect(page).to have_content("Pick List")
      expect(page).to have_content("May 9, 2014 between 7:00AM and 11:00AM")
      expect(page).to have_content("Ordering has not yet closed for this delivery")
      expect(page).to have_content(sellers.name)
    end
  end

  context "after the delivery cutoff" do
    before do
      Timecop.travel("May 9, 2014")
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
      visit admin_delivery_tools_pick_list_path(friday_delivery.id)
    end

    it "shows the pick list" do
      expect(page).to have_content("Pick List")
      expect(page).to have_content("May 9, 2014 between 7:00AM and 11:00AM")
      expect(page).to_not have_content("Ordering has not yet closed for this delivery")
      expect(page).to have_content(sellers.name)
    end
  end

  context "single order" do
    let!(:order)      { create(:order, organization: buyer1, market: market, delivery: friday_delivery) }
    let!(:order_item) { create(:order_item, order: order, product: product1, quantity: 1)}

    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
      visit admin_delivery_tools_pick_list_path(friday_delivery.id)
    end

    it "shows the pick list" do
      expect(page).to have_content("Pick List")
      expect(page).to have_content("May 9, 2014 between 7:00AM and 11:00AM")
      expect(page).to have_content(sellers.name)

      lines = Dom::Admin::PickListItem.all
      expect(lines.count).to eql(1)

      line = lines.first
      expect(line.name).to have_content(product1.name)
      expect(line.total_sold).to have_content("1")
      expect(line.buyer).to have_content(buyer1.name)
      expect(line.breakdown).to have_content("1")
    end
  end

  context "multiple orders" do
    let!(:order1)      { create(:order, organization: buyer1, market: market, delivery: friday_delivery) }
    let!(:order_item1) { create(:order_item, order: order1, product: product1, quantity: 1)}

    let!(:order2)      { create(:order, organization: buyer2, market: market, delivery: friday_delivery) }
    let!(:order_item2) { create(:order_item, order: order2, product: product1, quantity: 1)}

    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
      visit admin_delivery_tools_pick_list_path(friday_delivery.id)
    end

    it "shows the pick list" do
      expect(page).to have_content("Pick List")
      expect(page).to have_content("May 9, 2014 between 7:00AM and 11:00AM")
      expect(page).to have_content(sellers.name)

      lines = Dom::Admin::PickListItem.all
      expect(lines.count).to eql(1)

      line = lines.first
      expect(line.name).to have_content(product1.name)
      expect(line.total_sold).to have_content("2")
      expect(line.buyer).to have_content(buyer1.name)
      expect(line.breakdown).to have_content("1")
    end
  end

  context "lots" do
    context "single lot" do
      let!(:order)      { create(:order, organization: buyer1, market: market, delivery: friday_delivery) }
      let!(:order_item) { create(:order_item, order: order, product: product1, quantity: 1)}
      let!(:lot)        { create(:lot, product: product1, number: "123", quantity: 10) }
      let!(:order_item_lot) { create(:order_item_lot, order_item: order_item, lot: lot) }

      before do
        lot.number = "123"
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_pick_list_path(friday_delivery.id)
      end

      it "displays any numbered lots used" do
        line = Dom::Admin::PickListItem.first

        expect(line.name).to have_content(product1.name)
        expect(line.breakdown).to have_content("Lot #123: 1")
      end
    end

    context "spanning multiple lots" do
      let!(:order)      { create(:order, organization: buyer1, market: market, delivery: friday_delivery) }
      let!(:order_item) { create(:order_item, order: order, product: product1, quantity: 18)}
      let!(:lot1)       { create(:lot, product: product1, number: "123", quantity: 15)}
      let!(:order_item_lot1) { create(:order_item_lot, order_item: order_item, lot: lot1, quantity: 15) }
      let!(:lot2)       { create(:lot, product: product1, number: "456", quantity: 5)}
      let!(:order_item_lot2) { create(:order_item_lot, order_item: order_item, lot: lot2, quantity: 3) }

      before do
        lot1.number = "123"
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_pick_list_path(friday_delivery.id)
      end

      it "shows the pick list" do
        line = Dom::Admin::PickListItem.first

        expect(line.name).to have_content(product1.name)
        expect(line.total_sold).to have_content("18")
        expect(line.breakdown).to have_content("Lot #123: 15")
        expect(line.breakdown).to have_content("Lot #456: 3")
      end
    end
  end

end
