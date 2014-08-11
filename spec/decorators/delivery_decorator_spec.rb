require "spec_helper"

describe DeliveryDecorator do
  let(:delivery_schedule) { create( :delivery_schedule ) }
  let(:current_org) { create(:organization, :single_location, markets: [delivery_schedule.market]) }
  let(:draper_context) { {context: {current_organization: current_org}} }

  subject { create(:delivery, delivery_schedule: delivery_schedule).decorate }

  describe "#type" do
    context "when type is a delivery" do
      it "displays as a delivery" do
        expect(subject.type).to eq("Delivery:")
      end
    end

    context "when type is a pickup" do
      let(:delivery_schedule) { create( :delivery_schedule, :buyer_pickup) }

      it "displays as a pickup" do
        expect(subject.type).to eq("Pick up:")
      end
    end
  end

  describe "#display_date" do
    subject { create(:delivery, deliver_on: Time.parse("2014-05-15 06:00:00 EDT")).decorate }

    it "displays the date of the upcoming delivery" do
      expect(subject.display_date).to eq("Thursday May 15, 2014")
    end
  end

  describe "#time_range" do
    let(:delivery_schedule){
      create(:delivery_schedule,
             seller_delivery_start: "4:00 PM",
             seller_delivery_end: "7:00 PM")
    }

    context "schedule is a delivery" do
      it "returns the seller delivery times" do
        expect(subject.time_range).to eq("between 4:00PM and 7:00PM")
      end
    end

    context "schedule is a pickup" do
      let(:delivery_schedule) { create(:delivery_schedule, :buyer_pickup) }
      it "displays the pickup times" do
        delivery_schedule.buyer_pickup_start = "7:00 PM"
        delivery_schedule.buyer_pickup_end = "8:00 PM"
        delivery_schedule.save!

        expect(subject.time_range).to eq("between 7:00PM and 8:00PM")
      end
    end
  end

  describe "#display_display_locations" do
    subject { create(:delivery, delivery_schedule: delivery_schedule).decorate(draper_context) }

    context "delivery is pickup" do
      let(:delivery_schedule) { create(:delivery_schedule, :buyer_pickup)}

      it "should return the address of the pickup location" do
        expect(subject.display_locations).not_to be_nil
        expect(subject.display_locations.count).to eql(1)
        expect(subject.display_locations.first).to eql(delivery_schedule.buyer_pickup_location)
      end
    end

    context "delivery is dropoff" do
      let!(:delivery_schedule) { create( :delivery_schedule ) }

      it "should return the address of the buyers selected organization" do
        expect(subject.display_locations).not_to be_nil
        expect(subject.display_locations.count).to eql(1)
        expect(subject.display_locations.first).to eql(current_org.shipping_location)
      end

      context "and the selected organziation has multiple locations" do
        let!(:current_org) { create(:organization, :multiple_locations, markets: [delivery_schedule.market]) }

        it "returns a list of display_locations" do
          deleted = create(:location, organization: current_org, deleted_at: 1.minute.ago)

          expect(subject.display_locations.count).to eql(2)
          expect(subject.display_locations).to include(*current_org.locations.visible)
          expect(subject.display_locations).to_not include(deleted)
        end
      end
    end
  end
end
