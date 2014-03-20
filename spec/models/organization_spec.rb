require 'spec_helper'

describe Organization do

  it 'requires a name' do
    org = Organization.new
    expect(org).to_not be_valid
    expect(org).to have(1).error_on(:name)
  end

  describe "Scopes:" do
    describe "#selling" do
      let!(:seller) { create(:organization, :seller) }
      let!(:buyer) { create(:organization, :buyer) }

      it "only returns organizations that can sell" do
        result = Organization.selling
        expect(result.count).to eql(1)
        expect(result.first).to eql(seller)
      end
    end
  end

  describe "#default_location" do
    context "organization has one saved location" do
      let!(:location) { create(:location) }
      let!(:org) { location.organization }
      subject { org.default_location }

      it "returns the only location" do
        expect(subject.name).to eql(location.name)
      end
    end

    context "organization has many saved locations" do
      let!(:org) { create(:organization) }
      let!(:loc1) { create(:location, organization: org) }
      let!(:loc2) { create(:location, organization: org) }

      subject { org.default_location }

      it "returns the first location" do
        expect(subject.name).to eql(loc1.name)
      end
    end
  end

  describe "#shipping_location" do
    let(:org) { create(:organization) }

    it 'returns nil if we have no locations' do
      expect(org.shipping_location).to be_nil
    end

    it 'returns the location marked default_shipping' do
      loc = create(:location, organization: org, default_shipping: true)
      expect(org.shipping_location).to eq(loc)
    end

    it 'does not return a deleted location' do
      loc = create(:location, organization: org, default_shipping: true, deleted_at: 1.minute.ago)
      expect(org.shipping_location).to be_nil
    end

    it 'returns the right location' do
      create(:location, organization: org, default_shipping: true, deleted_at: 1.minute.ago)
      loc = create(:location, organization: org, default_shipping: true)
      expect(org.shipping_location).to eq(loc)
    end
  end

  context "factory" do
    it "has a location" do
      organization = create(:organization, :single_location)

      expect(organization.locations.count).to eq(1)
    end
  end
end
