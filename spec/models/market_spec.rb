require 'spec_helper'

describe Market do
  describe 'validates' do
    let!(:original_market) { FactoryGirl.create(:market) }

    it 'name is unique' do
      market = FactoryGirl.build(:market)
      market.name = original_market.name

      expect(market).to_not be_valid
      expect(market).to have(1).error_on(:name)
    end

    it 'subdomain is unique' do
      market = FactoryGirl.build(:market)
      market.subdomain = original_market.subdomain

      expect(market).to_not be_valid
      expect(market).to have(1).error_on(:subdomain)
    end
  end
end
