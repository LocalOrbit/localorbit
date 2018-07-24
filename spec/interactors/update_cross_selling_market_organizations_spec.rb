require 'spec_helper'

RSpec.describe UpdateCrossSellingMarketOrganizations do
  let(:destination_market) { create(:market, allow_cross_sell: true) }
  let(:source_market)      { create(:market, allow_cross_sell: true, cross_sells: [destination_market]) }
  let(:organization)       { create(:organization, :seller, markets: [source_market]) }
  subject(:perform) {
    described_class.perform(
      organization: organization,
      source_market_id: source_market.id,
      destination_market_ids: [destination_market.id])
  }

  context 'new and deleted records' do
    it 'creates new associations' do
      expect {
        perform
      }.to change(organization.cross_sells, :count).by(1)
    end

    it 'removes missing associations' do
      perform
      expect {
        described_class.perform(
          organization: organization,
          source_market_id: source_market.id,
          destination_market_ids: [])
      }.to change(organization.cross_sells, :count).by(-1)
    end

    it 'soft deletes the removed missing associations' do
      perform
      expect {
        described_class.perform(
          organization: organization,
          source_market_id: source_market.id,
          destination_market_ids: [])
      }.to_not change(MarketOrganization, :count)
    end

    it 'doesn’t touch unchanged associations' do
      perform
      expect {
        described_class.perform(
          organization: organization,
          source_market_id: source_market.id,
          destination_market_ids: [destination_market.id])
      }.to_not change(organization.cross_sells, :count)
    end

    it 'ignores cross sells originating from other markets' do
      other_source_market = create(:market, allow_cross_sell: true, cross_sells: [destination_market])
      described_class.perform(
        organization: organization,
        source_market_id: other_source_market.id,
        destination_market_ids: [destination_market.id])

      expect {
        described_class.perform(
          organization: organization,
          source_market_id: source_market.id,
          destination_market_ids: [])
      }.to_not change(organization.cross_sells, :count)
    end
  end

  context 'without required arguments' do
    it 'raises RuntimeError' do
      expect { described_class.perform(organization: organization, source_market_id: source_market.id) }.to raise_error RuntimeError
      expect { described_class.perform(organization: organization, destination_market_ids: [destination_market.id]) }.to raise_error RuntimeError
      expect { described_class.perform(source_market_id: source_market.id, destination_market_ids: [destination_market.id]) }.to raise_error RuntimeError
    end
  end
end
