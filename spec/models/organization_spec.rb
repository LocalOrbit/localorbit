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

  describe ".default_location" do
    context "organization has no saved locations" do
      let(:org) { Organization.new }
      subject { org.default_location }

      it "builds a location" do
        expect(subject).to be_a(Location)
        expect(subject).not_to be_persisted
      end
    end

    context "organization has one saved location" do
      let!(:location) { create(:location) }
      let!(:org) { location.organization }
      subject { org.default_location }

      it "returns the only location" do
        expect(subject).to eql(location)
      end
    end

    context "organization has many saved locations" do
      let!(:org) { create(:organization) }
      let!(:loc1) { create(:location, organization: org) }
      let!(:loc2) { create(:location, organization: org) }

      subject { org.default_location }

      it "returns the first location" do
        expect(subject).to eql(loc1)
      end
    end
  end
end
