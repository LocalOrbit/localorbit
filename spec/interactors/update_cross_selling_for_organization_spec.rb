require 'spec_helper'

RSpec.describe UpdateCrossSellingForOrganization do
  let(:organization) { build_stubbed(:organization) }
  let(:source_to_destination_maps) { {1 => [2, 3]} }

  it 'calls UpdateCrossSellingForMarkets' do
    expect(UpdateCrossSellingForMarkets).to receive(:perform)
    described_class.perform(organization: organization, source_to_destination_maps: source_to_destination_maps)
  end

  it 'calls UpdateDeliverySchedulesForProducts' do
    expect(UpdateCrossSellingForMarkets).to receive(:perform)
    described_class.perform(organization: organization, source_to_destination_maps: source_to_destination_maps)
  end

  context 'without required arguments' do
    it 'raises RuntimeError' do
      expect { described_class.perform(organization: organization) }.to raise_error RuntimeError
      expect { described_class.perform(source_to_destination_maps: source_to_destination_maps) }.to raise_error RuntimeError
    end
  end
end
