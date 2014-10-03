require "spec_helper"

describe DeliverySchedule do
  let(:market) { create(:market, :with_addresses) }

  describe "validates" do

    [:day, :buyer_day].each do |field|
      describe field.to_s do
        before do
          subject.update_attributes(market: market, seller_fulfillment_location: market.addresses.first)
        end
        it "is required" do
          expect(subject).to have(1).error_on(field)
        end

        it "is greater than or equal to 0" do
          subject.send("#{field}=", -1)
          expect(subject).to have(1).error_on(field)
        end

        it "is less than or equal to 6" do
          subject.send("#{field}=", 7)
          expect(subject).to have(1).error_on(field)
        end

        it "with valid day" do
          subject.send("#{field}=", 0)
          expect(subject).to have(0).error_on(field)
          subject.send("#{field}=", 6)
          expect(subject).to have(0).error_on(field)
        end
      end
    end

    describe "order_cutoff" do
      it "is required" do
        subject.order_cutoff = nil
        expect(subject).to have(1).error_on(:order_cutoff)
      end

      it "is greater than or equal to 6" do
        subject.order_cutoff = 5
        expect(subject).to have(1).error_on(:order_cutoff)
      end

      it "is less than or equal to 504" do
        subject.order_cutoff = 505
        expect(subject).to have(1).error_on(:order_cutoff)
      end

      it "with valid order_cutoff" do
        subject.order_cutoff = 6
        expect(subject).to have(0).error_on(:order_cutoff)

        subject.order_cutoff = 504
        expect(subject).to have(0).error_on(:order_cutoff)
      end
    end

    it "seller_fulfillment_location_id is required" do
      expect(subject).to have(1).error_on(:seller_fulfillment_location_id)
    end

    it "seller_delivery_start is required" do
      expect(subject).to have(1).error_on(:seller_delivery_start)
    end

    describe "seller_delivery_end" do
      it "is required" do
        expect(subject).to have(1).error_on(:seller_delivery_end)
      end

      it "must be after seller_delivery_start" do
        subject.seller_delivery_start = "8:00 AM"
        subject.seller_delivery_end   = "7:00 AM"

        expect(subject).to have(1).error_on(:seller_delivery_end)
      end
    end

    describe "with a seller_fulfillment_location_id of 0" do
      before do
        subject.seller_fulfillment_location_id = 0
      end

      it "does not require buyer info" do
        expect(subject).to have(0).error_on(:buyer_pickup_location_id)
        expect(subject).to have(0).error_on(:buyer_pickup_start)
        expect(subject).to have(0).error_on(:buyer_pickup_end)
      end
    end

    describe "with a seller_fulfillment_location_id greater than 0" do
      let!(:location) { create(:market_address, market: market) }

      before do
        subject.seller_fulfillment_location_id = location.id
      end

      it "buyer_pickup_location_id is required" do
        expect(subject).to have(1).error_on(:buyer_pickup_location_id)
      end

      describe "buyer_pickup_start" do
        it "is required" do
          expect(subject).to have(1).error_on(:buyer_pickup_start)
        end
        it "need not be after seller_delivery_start" do
          subject.seller_delivery_start = "8:00 AM"
          subject.buyer_pickup_start    = "7:00 AM"

          expect(subject).to have(0).error_on(:buyer_pickup_start)
        end
      end

      describe "buyer_pickup_end" do
        it "is required" do
          expect(subject).to have(1).error_on(:buyer_pickup_end)
        end

        it "must be after buyer_pickup_start" do
          subject.buyer_pickup_start = "8:00 AM"
          subject.buyer_pickup_end   = "7:00 AM"

          expect(subject).to have(1).error_on(:buyer_pickup_end)
        end
      end

    end
    describe "seller and buyer days" do
      describe "when fulfillment method is 'Direct to customer'" do
        let(:sched) { create(:delivery_schedule, :direct_to_customer) }
        it "requires 'day' and 'buyer_day' fields to be equal" do
          expect(sched).to be_valid
          expect(sched.day).to eq(sched.buyer_day)

          sched.day += 1

          expect(sched).not_to be_valid
          expect(sched).to have(1).error
          expect(sched).to have(1).error_on(:day)
          expect(sched.errors[:day].first).to match(/match.*direct/i)
        end
      end

      describe "when fulfillment method is NOT 'Direct to customer'" do
        let(:sched) { create(:delivery_schedule, :buyer_pickup) }
        it "allows 'day' and 'buyer_day' fields to be different" do
          expect(sched).to be_valid
          expect(sched.day).to eq(sched.buyer_day)

          sched.day += 1
          expect(sched).to be_valid
        end
      end
    end
  end

  describe "buyer_day and day fields cross-default" do 
    it "copies 'day' to 'buyer_day' if 'buyer_day' is not set" do
      subject.buyer_day = nil
      subject.day = 5
      subject.valid? # trigger the defaulting
      expect(subject.day).to eq(5)
      expect(subject.buyer_day).to eq(5)
    end

    it "copies 'buyer_day' to 'day' if 'day' is not set" do
      subject.buyer_day = 3
      subject.day = nil
      subject.valid? # trigger the defaulting
      expect(subject.day).to eq(3)
      expect(subject.buyer_day).to eq(3)
    end
  end

  describe "#next_delivery" do
    let(:market) { create(:market, :with_addresses, timezone: "US/Eastern") }

    let(:base_schedule) { { market: market, order_cutoff: 8, 
                        day: 4, 
                        seller_delivery_start: "6:00 am", 
                        seller_delivery_end: "10:00 am",
                        buyer_pickup_start: "9:00 am", 
                        buyer_pickup_end: "11:00 am"} }

    let(:schedule) { create(:delivery_schedule, base_schedule) }

    let(:offset_schedule) { create(:delivery_schedule, :hub_to_buyer,
                                   base_schedule.merge(buyer_day: 5)) }


    before do
      Timecop.freeze(Time.parse "May 10, 2014 06:00")
    end

    after do
      Timecop.return
    end

    describe "delivery with short cutoff" do
      it "creates a delivery for the next delivery time" do
        delivery = schedule.next_delivery
        expected_deliver_on_time = Time.parse("2014-05-15 06:00:00 EDT")
        expected_buyer_deliver_on_time = Time.parse("2014-05-15 09:00:00 EDT")

        expect(delivery).to be_a(Delivery)
        expect(delivery.deliver_on).to eql(expected_deliver_on_time)
        expect(delivery.buyer_deliver_on).to eql(expected_buyer_deliver_on_time)
      end
    end

    describe "when the seller delivery day is different than the buyer pickup day" do
      it "creates proper buyer_deliver_on time based on buyer day/time" do
        delivery = offset_schedule.next_delivery
        expected_deliver_on_time = Time.parse("2014-05-15 06:00:00 EDT")
        expected_buyer_deliver_on_time = Time.parse("2014-05-16 09:00:00 EDT")
        expect(delivery.deliver_on).to eql(expected_deliver_on_time)
        expect(delivery.buyer_deliver_on).to eql(expected_buyer_deliver_on_time)
      end
    end


    describe "when the delivery cutoff is weeks before the current time" do
      before do
        schedule.order_cutoff = 3 * 7 * 24
        schedule.save!
      end

      it "creates a delivery for the next delivery time" do
        delivery = schedule.next_delivery
        expected_time = Time.parse("2014-06-05 06:00:00 EDT")
        expected_buyer_time = Time.parse("2014-06-05 09:00:00 EDT")

        expect(delivery).to be_a(Delivery)
        expect(delivery.deliver_on).to eql(expected_time)
        expect(delivery.buyer_deliver_on).to eql(expected_buyer_time)
      end

      it "creates proper buyer_deliver_on time based on buyer day/time" do
        delivery = offset_schedule.next_delivery
        expected_deliver_on_time = Time.parse("2014-05-15 06:00:00 EDT")
        expected_buyer_deliver_on_time = Time.parse("2014-05-16 09:00:00 EDT")

        expect(delivery.deliver_on).to eql(expected_deliver_on_time)
        expect(delivery.buyer_deliver_on).to eql(expected_buyer_deliver_on_time)
      end
    end

    context "the next delivery already exists" do
      let(:deliver_on_date) { Time.parse("2014-05-15 06:00:00 EDT") }
      let!(:delivery) { create(:delivery, delivery_schedule: schedule, deliver_on: deliver_on_date) }

      it "returns the found deilvery" do
        expect(schedule.next_delivery).to eql(delivery)
      end
    end
  end

  describe "#buyer_pickup?" do
    it "is true if both the seller fulfillment location and buyer pickup location are set" do
      ds = create(:delivery_schedule, :buyer_pickup)
      expect(ds.seller_fulfillment_location).to_not be_nil
      expect(ds.buyer_pickup_location).to_not be_nil

      expect(ds.buyer_pickup?).to eq(true)
    end

    it "is false if either location is nil" do
      ds = create(:delivery_schedule, :buyer_pickup)
      ds.seller_fulfillment_location = nil
      expect(ds.buyer_pickup?).to eq(false)

      ds.seller_fulfillment_location = ds.buyer_pickup_location
      ds.buyer_pickup_location = nil
      expect(ds.buyer_pickup?).to eq(false)

      ds.seller_fulfillment_location = nil
      expect(ds.buyer_pickup?).to eq(false)
    end
  end

  describe "#participating_products" do
    let!(:origin_market) { create(:market) }

    let!(:market_org)     { create(:organization, markets: [market]) }
    let!(:cross_sell_org) do
      create(:organization, markets: [origin_market]).tap do |o|
        o.update_cross_sells!(from_market: origin_market, to_ids: [market.id])
      end
    end

    let!(:in_market_opt_in)   { create(:product, organization: market_org, delivery_schedules: [delivery_schedule]) }
    let!(:in_market_opt_out)  { create(:product, organization: market_org).tap {|p| p.delivery_schedules.clear } }
    let!(:cross_sell_opt_in)  { create(:product, organization: cross_sell_org, delivery_schedules: [delivery_schedule]) }
    let!(:cross_sell_opt_out) { create(:product, organization: cross_sell_org).tap {|p| p.delivery_schedules.clear } }

    subject { delivery_schedule.participating_products }

    context "all seller required to participate" do
      let!(:delivery_schedule) { create(:delivery_schedule, market: market, require_delivery: true, require_cross_sell_delivery: true) }

      it "includes all products" do
        expect(subject.size).to eq(4)
        expect(subject).to include(*Product.all)
      end
    end

    context "all market sellers required to participate" do
      let!(:delivery_schedule) { create(:delivery_schedule, market: market, require_delivery: true, require_cross_sell_delivery: false) }

      it "includes all but the cross sell opt out" do
        expect(subject.size).to eq(3)
        expect(subject).to include(in_market_opt_in, in_market_opt_out, cross_sell_opt_in)
      end
    end

    context "all cross sell sellers required to participate" do
      let!(:delivery_schedule) { create(:delivery_schedule, market: market, require_delivery: false, require_cross_sell_delivery: true) }

      it "includes all but the in market opt out" do
        expect(subject.size).to eq(3)
        expect(subject).to include(in_market_opt_in, cross_sell_opt_in, cross_sell_opt_out)
      end
    end

    context "no participation requirement" do
      let!(:delivery_schedule) { create(:delivery_schedule, market: market, require_delivery: false, require_cross_sell_delivery: false) }

      it "includes only the opt ins" do
        expect(subject.size).to eq(2)
        expect(subject).to include(in_market_opt_in, cross_sell_opt_in)
      end
    end
  end

  describe "#required?" do
    let(:other_market)   { create(:market, allow_cross_sell: true) }
    let(:primary_org)    { create(:organization, :seller, markets: [market]) }
    let(:cross_sell_org) do
      create(:organization, :seller).tap do |org|
        org.update_cross_sells!(from_market: other_market, to_ids: [market.id])
      end
    end
    let(:delivery_schedule) { create(:delivery_schedule, market: market, require_delivery: @require_primary_org_delivery, require_cross_sell_delivery: @require_cross_sell_org_delivery) }

    it "is false if neither cross sell or primary orgs are required to deliver" do
      @require_primary_org_delivery, @require_cross_sell_org_delivery = false, false

      expect(delivery_schedule.required?(primary_org)).to be_falsy
      expect(delivery_schedule.required?(cross_sell_org)).to be_falsy
    end

    it "is false if only cross sell orgs are requied to deliver and org is primary" do
      @require_primary_org_delivery, @require_cross_sell_org_delivery = false, true

      expect(delivery_schedule.required?(primary_org)).to be_falsy
    end

    it "is false if only primary orgs are required to deliver and org is cross sell" do
      @require_primary_org_delivery, @require_cross_sell_org_delivery = true, false

      expect(delivery_schedule.required?(cross_sell_org)).to be_falsy
    end

    it "is true if primary orgs are required to deliver and org is primary" do
      @require_primary_org_delivery, @require_cross_sell_org_delivery = true, false

      expect(delivery_schedule.required?(primary_org)).to be_truthy
    end

    it "is true if cross sell orgs are required to deliver and org is cross sell" do
      @require_primary_org_delivery, @require_cross_sell_org_delivery = false, true

      expect(delivery_schedule.required?(cross_sell_org)).to be_truthy
    end

    it "is true if both kinds of orgs are required to deliver and org is primary" do
      @require_primary_org_delivery, @require_cross_sell_org_delivery = true, true

      expect(delivery_schedule.required?(primary_org)).to be_truthy
    end

    it "is true if both kinds of orgs are required to deliver and org is cross sell" do
      @require_primary_org_delivery, @require_cross_sell_org_delivery = true, true

      expect(delivery_schedule.required?(cross_sell_org)).to be_truthy
    end
  end


  describe "soft_delete" do
    include_context "soft delete-able models"
    it_behaves_like "a soft deleted model"
  end

  describe "weekday" do
    it "maps the current day value to the friendly weekday name" do
      %w{Sunday Monday Tuesday Wednesday Thursday Friday Saturday}.each.with_index do |day_name,i|
        subject.day = i
        expect(subject.weekday).to eq(day_name)
      end
    end
  end

  describe "buyer_weekday" do
    it "maps the current buyer_day value to the friendly weekday name" do
      %w{Sunday Monday Tuesday Wednesday Thursday Friday Saturday}.each.with_index do |day_name,i|
        subject.buyer_day = i
        expect(subject.buyer_weekday).to eq(day_name)
      end
    end
  end


end
