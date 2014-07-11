require 'spec_helper'

describe DeliverySchedule do
  let(:market) { create(:market) }

  describe 'validates' do
    describe 'day' do
      it 'is required' do
        expect(subject).to have(1).error_on(:day)
      end

      it 'is greater than or equal to 0' do
        subject.day = -1
        expect(subject).to have(1).error_on(:day)
      end

      it 'is less than or equal to 6' do
        subject.day = 7
        expect(subject).to have(1).error_on(:day)
      end

      it 'with valid day' do
        subject.day = 0
        expect(subject).to have(0).error_on(:day)

        subject.day = 6
        expect(subject).to have(0).error_on(:day)
      end
    end

    describe 'order_cutoff' do
      it 'is required' do
        subject.order_cutoff = nil
        expect(subject).to have(1).error_on(:order_cutoff)
      end

      it 'is greater than or equal to 6' do
        subject.order_cutoff = 5
        expect(subject).to have(1).error_on(:order_cutoff)
      end

      it 'is less than or equal to 504' do
        subject.order_cutoff = 505
        expect(subject).to have(1).error_on(:order_cutoff)
      end

      it 'with valid order_cutoff' do
        subject.order_cutoff = 6
        expect(subject).to have(0).error_on(:order_cutoff)

        subject.order_cutoff = 504
        expect(subject).to have(0).error_on(:order_cutoff)
      end
    end

    it 'seller_fulfillment_location_id is required' do
      expect(subject).to have(1).error_on(:seller_fulfillment_location_id)
    end

    it 'seller_delivery_start is required' do
      expect(subject).to have(1).error_on(:seller_delivery_start)
    end

    describe 'seller_delivery_end' do
      it 'is required' do
        expect(subject).to have(1).error_on(:seller_delivery_end)
      end

      it 'must be after seller_delivery_start' do
        subject.seller_delivery_start = '8:00 AM'
        subject.seller_delivery_end   = '7:00 AM'

        expect(subject).to have(1).error_on(:seller_delivery_end)
      end
    end

    describe 'with a seller_fulfillment_location_id of 0' do
      before do
        subject.seller_fulfillment_location_id = 0
      end

      it 'does not require buyer info' do
        expect(subject).to have(0).error_on(:buyer_pickup_location_id)
        expect(subject).to have(0).error_on(:buyer_pickup_start)
        expect(subject).to have(0).error_on(:buyer_pickup_end)
      end
    end

    describe 'with a seller_fulfillment_location_id greater than 0' do
      let!(:location) { create(:market_address, market: market) }

      before do
        subject.seller_fulfillment_location_id = location.id
      end

      it 'buyer_pickup_location_id is required' do
        expect(subject).to have(1).error_on(:buyer_pickup_location_id)
      end

      describe 'buyer_pickup_start' do
        it 'is required' do
          expect(subject).to have(1).error_on(:buyer_pickup_start)
        end

        it 'must be after seller_delivery_start' do
          subject.seller_delivery_start = '8:00 AM'
          subject.buyer_pickup_start    = '7:00 AM'

          expect(subject).to have(1).error_on(:buyer_pickup_start)
        end
      end

      describe 'buyer_pickup_end' do
        it 'is required' do
          expect(subject).to have(1).error_on(:buyer_pickup_end)
        end

        it 'must be after buyer_pickup_start' do
          subject.buyer_pickup_start = '8:00 AM'
          subject.buyer_pickup_end   = '7:00 AM'

          expect(subject).to have(1).error_on(:buyer_pickup_end)
        end
      end
    end
  end

  describe "#next_delivery" do
    let(:market) { create(:market, timezone: "US/Eastern") }
    let(:schedule) {
      create(:delivery_schedule, market: market,
             order_cutoff: 6, seller_delivery_start: "6:00 am", seller_delivery_end: "10:00 am", day:4)
    }

    before do
      Timecop.freeze(Time.parse "May 10, 2014 06:00")
    end

    after do
      Timecop.return
    end

    describe "delivery with short cutoff" do
      it "creates a delivery for the next delivery time" do
        delivery = schedule.next_delivery
        expected_time = Time.parse("2014-05-15 06:00:00 EDT")

        expect(delivery).to be_a(Delivery)
        expect(delivery.deliver_on).to eql(expected_time)
      end
    end

    describe "when the delivery cutoff is weeks before the current time" do
      before do
        schedule.order_cutoff = 3*7*24
        schedule.save!
      end

      it "creates a delivery for the next delivery time" do
        delivery = schedule.next_delivery()
        expected_time = Time.parse("2014-06-05 06:00:00 EDT")

        expect(delivery).to be_a(Delivery)
        expect(delivery.deliver_on).to eql(expected_time)
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
    it 'is true if both the seller fulfillment location and buyer pickup location are set' do
      ds = create(:delivery_schedule, :buyer_pickup)
      expect(ds.seller_fulfillment_location).to_not be_nil
      expect(ds.buyer_pickup_location).to_not be_nil

      expect(ds.buyer_pickup?).to eq(true)
    end

    it 'is false if either location is nil' do
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
end
