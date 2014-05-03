require 'spec_helper'

describe Organization do

  describe 'validates' do
    describe 'name' do
      it 'is required' do
        org = Organization.new
        expect(org).to_not be_valid
        expect(org).to have(1).error_on(:name)
      end

      it 'is at most 255 characters long' do
        org = Organization.new(name: 'a' * 256)
        expect(org).to_not be_valid
        expect(org).to have(1).error_on(:name)
      end
    end
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

  describe "#cross_sells" do
    let!(:cross_sell_market)  { create(:market, allow_cross_sell: true) }
    let!(:wednesday_delivery) { create(:delivery_schedule, market: cross_sell_market, day: 3) }

    let!(:market)             { create(:market, allow_cross_sell: true, cross_sells: [cross_sell_market]) }
    let!(:monday_delivery)    { create(:delivery_schedule, market: market, day: 1) }
    let!(:organization)       { create(:organization, :seller, markets: [market]) }

    context "using all deliveries" do
      let!(:product) { create(:product, :sellable, organization: organization) }

      it 'adds a markets delivery schedules to products on adding to #cross_sells' do
        expect {
          organization.cross_sell_ids = [cross_sell_market.id]
          organization.market_organizations.where(market_id: [cross_sell_market.id]).update_all(cross_sell: true)
        }.to change {
          product.reload.delivery_schedules.count
        }.from(1).to(2)
      end

      it 'removes a markets delivery schedules from a product on removing from #cross_sells' do
        organization.cross_sell_ids = [cross_sell_market.id]
        organization.market_organizations.where(market_id: [cross_sell_market.id]).update_all(cross_sell: true)

        expect {
          organization.cross_sell_ids = []
        }.to change {
          product.reload.delivery_schedules.count
        }.from(2).to(1)
      end
    end

    context "manually managing deliveries" do
      let!(:product) { create(:product, :sellable, use_all_deliveries: false, organization: organization) }

      it 'adding a markets to #cross_sells does not add its delivery schedules to products' do
        expect {
          organization.cross_sell_ids = [cross_sell_market.id]
          organization.market_organizations.where(market_id: [cross_sell_market.id]).update_all(cross_sell: true)
        }.to_not change {
          product.reload.delivery_schedules.count
        }.from(0)
      end

      it 'removing a markets from #cross_sells removes its delivery schedules' do
        organization.cross_sell_ids = [cross_sell_market.id]
        organization.market_organizations.where(market_id: [cross_sell_market.id]).update_all(cross_sell: true)

        product.delivery_schedules << wednesday_delivery

        expect {
          organization.cross_sell_ids = []
        }.to change {
          product.reload.delivery_schedules.count
        }.from(1).to(0)
      end
    end
  end
end
