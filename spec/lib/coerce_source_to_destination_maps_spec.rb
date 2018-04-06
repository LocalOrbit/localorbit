require 'spec_helper'

RSpec.describe CoerceSourceToDestinationMaps do

  subject(:call) { described_class.call(stdm) }

  describe '.call' do
    let(:stdm) { {'1' => ['', '1', '2'], '2' => ['3', '4']} }

    it 'removes empty values' do
      expect(call[1][0]).to be 1
    end

    it 'transforms strings to integers' do
      expect(call).to be == {1 => [1, 2], 2 => [3, 4]}
    end
  end
end
