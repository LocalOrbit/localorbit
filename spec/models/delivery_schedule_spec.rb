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

  describe "#current" do
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
        delivery = schedule.next_delivery()
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

    context "no deliveries exist associated with it"
    context "delivery for schedule does not exist"
    context "devlivery time is in"
    context "given a delivery whos delivery time is in future which has a cutoff that occurs in the future"
    context "given a delivery "
  end


end
