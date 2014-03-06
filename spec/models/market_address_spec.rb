require 'spec_helper'

describe MarketAddress do
  let!(:market) { create(:market) }
  it 'requires a name' do
    subject = MarketAddress.new(address: '123 Apple', city: 'Holland', state: 'MI', zip: '49423', market: market)
    expect(subject.save).to eq(false)
    expect(subject.errors.any?).to eq(true)
    expect(subject.errors.messages.keys.count).to eq(1)
    expect(subject.errors.messages).to have_key(:name)
  end
  
  it 'requires an address' do
    subject = MarketAddress.new(name: 'new address', city: 'Holland', state: 'MI', zip: '49423', market: market)
    expect(subject.save).to eq(false)
    expect(subject.errors.any?).to eq(true)
    expect(subject.errors.messages.keys.count).to eq(1)
    expect(subject.errors.messages).to have_key(:address)
  end
  
  it 'requires a city' do
    subject = MarketAddress.new(name: 'new address', address: '123 Apple', state: 'MI', zip: '49423', market: market)
    expect(subject.save).to eq(false)
    expect(subject.errors.any?).to eq(true)
    expect(subject.errors.messages.keys.count).to eq(1)
    expect(subject.errors.messages).to have_key(:city)
  end
  
  it 'requires a state' do
    subject = MarketAddress.new(name: 'new address', address: '123 Apple', city: 'Holland', zip: '49423', market: market)
    expect(subject.save).to eq(false)
    expect(subject.errors.any?).to eq(true)
    expect(subject.errors.messages.keys.count).to eq(1)
    expect(subject.errors.messages).to have_key(:state)
  end
  
  it 'requires a zip' do
    subject = MarketAddress.new(name: 'new address', address: '123 Apple', city: 'Holland', state: 'MI', market: market)
    expect(subject.save).to eq(false)
    expect(subject.errors.any?).to eq(true)
    expect(subject.errors.messages.keys.count).to eq(1)
    expect(subject.errors.messages).to have_key(:zip)
  end
  
  it 'requires a market' do
    subject = MarketAddress.new(name: 'new address', address: '123 Apple', city: 'Holland', state: 'MI', zip: '49423')
    expect(subject.save).to eq(false)
    expect(subject.errors.any?).to eq(true)
    expect(subject.errors.messages.keys.count).to eq(1)
    expect(subject.errors.messages).to have_key(:market)
  end

  describe "soft_delete" do
    subject { create(:market_address, market: market) }
    it_behaves_like "a soft deleted model"
  end
end
