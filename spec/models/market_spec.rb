require 'spec_helper'

describe Market do
  describe 'validates' do
    let!(:original_market) { create(:market) }

    it 'name is unique' do
      market = build(:market)
      market.name = original_market.name

      expect(market).to_not be_valid
      expect(market).to have(1).error_on(:name)
    end

    it 'subdomain is unique' do
      market = build(:market)
      market.subdomain = original_market.subdomain

      expect(market).to_not be_valid
      expect(market).to have(1).error_on(:subdomain)
    end
  end

  describe 'before_save' do
    let(:market) { build(:market) }

    it 'remove @ from twitter slug' do
      market.twitter = '@collectiveidea'

      expect(market.save!).to be true
      market.reload
      expect(market.twitter).to eq('collectiveidea')
    end

    it "leaves the twitter slug alone if it doesn't start with @" do
      market.twitter = 'collectiveidea'

      expect(market.save!).to be true
      market.reload
      expect(market.twitter).to eq('collectiveidea')
    end
  end

  describe '#fulfillment_locations' do
    let!(:market) { create(:market) }
    let!(:address1) { create(:market_address, market: market) }
    let!(:address2) { create(:market_address, market: market) }
    let(:default_name) { 'Direct to seller' }
    subject { market.fulfillment_locations(default_name) }

    it 'accepts a parameter as default option name' do
      expect(subject).to include([default_name, 0])
    end

    it 'has market address names' do
      expect(subject).to include([address1.name, address1.id])
      expect(subject).to include([address2.name, address2.id])
    end
  end

  describe "domain" do
    let(:market) { build(:market) }

    it "is is the subdomain with the canonical domain" do
      expect(market.domain).to eq("#{market.subdomain}.#{Figaro.env.domain!}")
    end
  end
end
