require "spec_helper"

describe Location do
  let(:organization) { create(:organization) }

  describe "soft_delete" do
    include_context "soft delete-able models"
    it_behaves_like "a soft deleted model"
  end

  context "validations" do
    it "requires an organization" do
      expect(subject).to have(1).error_on(:organization)
    end

    context "there is only one default_billing location" do
      let(:org) { create(:organization) }

      it "when adding a new location" do
        create(:location, organization: org)
        subject.organization = org
        subject.default_billing = true

        expect(subject).to have(1).error_on(:default_billing)
      end

      it "after a soft delete" do
        location = create(:location, organization: org, deleted_at: 1.minute.ago)
        subject.organization = org
        subject.default_billing = true

        expect(subject).to have(0).error_on(:default_billing)
      end

      it "ignores soft deleted organization locations on validation" do
        create(:location, name: "test", organization: org, deleted_at: 1.day.ago)
        subject = create(:location, name: "test", organization: org)
        expect(subject).to have(0).errors_on(:name)
        subject.soft_delete
        subject = create(:location, name: "test", organization: org)
        expect(subject).to have(0).errors_on(:name)
      end
    end

    context "there is only one default_shipping location" do
      let(:org) { create(:organization) }

      it "when adding a new location" do
        create(:location, organization: org)
        subject.organization = org
        subject.default_shipping = true

        expect(subject).to have(1).error_on(:default_shipping)
      end

      it "after a soft delete" do
        location = create(:location, organization: org, deleted_at: 1.minute.ago)
        subject.organization = org
        subject.default_shipping = true

        expect(subject).to have(0).error_on(:default_shipping)
      end
    end
  end

  describe "supports geocoding" do
    before(:all) do
      @canned_geocoder = Geocode.geocoder
      Geocode.geocoder = @canned_geocoder.previous_geocoder
    end

    after(:all) do
      Geocode.geocoder = @canned_geocoder
    end

    describe "handles US addresses" do
      let(:loc) { Location.new({ address: '206 S 5th Ave #200', city: 'Ann Arbor', state: 'MI', zip: '48104' }) }
      before(:each) do
        VCR.use_cassette('mapbox-ann-arbor-address-geocode', :record => :none) do
          loc.send(:attach_geocode)
        end
      end
      it "returns a US coordinate" do
        expect(loc.geocode.country).to eq("United States")
        expect(loc.geocode.latitude).to be_within(0.001).of(42.2802803)
        expect(loc.geocode.longitude).to be_within(0.001).of(-83.7462621)
      end
    end

    describe "handles Canadian addresses" do
      let(:loc) { Location.new({ address: '706 2nd Ave NW', city: 'Calgary', state: 'AB', zip: 'T2N0E3', country: 'CA' }) }
      before(:each) do
        VCR.use_cassette('mapbox-calgary-address-geocode', :record => :none) do
          loc.send(:attach_geocode)
        end
      end
      it "returns a Canadian coordinate" do
        pending("mapbox doesn't handle Canadian addresses")
        expect(loc.geocode.country).to eq("Canada")
        expect(loc.geocode.latitude).to be_within(0.001).of(51.0581117)
        expect(loc.geocode.longitude).to be_within(0.001).of(-114.078345)
      end
    end

    describe "handles Canadian cities" do
      let(:loc) { Location.new({ city: 'Calgary', state: 'AB', zip: 'T2N0E3', country: 'CA' }) }
      before(:each) do
        VCR.use_cassette('mapbox-calgary-city-geocode', :record => :none) do
          loc.send(:attach_geocode)
        end
      end
      it "returns a Canadian coordinate" do
        expect(loc.geocode.country).to eq("Canada")
        expect(loc.geocode.latitude).to be_within(0.1).of(51.0579099)
        expect(loc.geocode.longitude).to be_within(0.1).of(-114.0787911)
      end
    end
  end

  context "first location on an organization" do
    it "sets default billing" do
      location = create(:location, organization: organization)

      expect(location.default_billing).to eq(true)
    end

    it "sets default shipping" do
      location = create(:location, organization: organization)

      expect(location.default_shipping).to eq(true)
    end

    context "after a location is soft deleted" do
      let!(:deleted_location) { create(:location, organization: organization, deleted_at: 1.minute.ago) }

      it "sets default billing" do
        location = create(:location, organization: organization)

        expect(location.default_billing).to eq(true)
      end

      it "sets default shipping" do
        location = create(:location, organization: organization)

        expect(location.default_shipping).to eq(true)
      end
    end
  end

  context "deleting the default_billing address" do
    let!(:default_loc) { create(:location, organization: organization) }

    it "allows you to delete your only location" do
      default_loc.soft_delete
      expect(Location.visible.count).to eq(0)
    end

    it "makes the first remaining location the default" do
      other_loc = create(:location, organization: organization)

      default_loc.soft_delete
      other_loc.reload
      expect(other_loc).to be_default_billing
    end
  end

  context "deleting the default_shipping address" do
    let!(:default_loc) { create(:location, organization: organization) }

    it "allows you to delete your only location" do
      default_loc.soft_delete
      expect(Location.visible.count).to eq(0)
    end

    it "makes the first remaining location the default" do
      other_loc = create(:location, organization: organization)

      default_loc.soft_delete
      other_loc.reload
      expect(other_loc).to be_default_shipping
    end
  end
end
