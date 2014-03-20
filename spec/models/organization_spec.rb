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
