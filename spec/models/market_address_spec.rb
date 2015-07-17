require "spec_helper"

describe MarketAddress do
  let!(:market) { create(:market) }
  it "does not require a name" do
    expect(subject).to have(0).errors_on(:name)
    #expect(subject.name).to eq("Default Address") # nil at this point, ?
  end

  it "ignores soft deleted market addresses in name validation" do
    create(:market_address, name: "test", market: market, deleted_at: 1.day.ago)
    subject = create(:market_address, name: "test", market: market)
    expect(subject).to have(0).errors_on(:name)
    subject.soft_delete
    subject = create(:market_address, name: "test", market: market)
    expect(subject).to have(0).errors_on(:name)
  end

  it "requires an address" do
    subject = MarketAddress.new(name: "new address", city: "Holland", state: "MI", zip: "49423", market: market)
    expect(subject.save).to eq(false)
    expect(subject.errors.any?).to eq(true)
    expect(subject.errors.messages.keys.count).to eq(1)
    expect(subject.errors.messages).to have_key(:address)
  end

  it "requires a city" do
    subject = MarketAddress.new(name: "new address", address: "123 Apple", state: "MI", zip: "49423", market: market)
    expect(subject.save).to eq(false)
    expect(subject.errors.any?).to eq(true)
    expect(subject.errors.messages.keys.count).to eq(1)
    expect(subject.errors.messages).to have_key(:city)
  end

  it "requires a state" do
    subject = MarketAddress.new(name: "new address", address: "123 Apple", city: "Holland", zip: "49423", market: market)
    expect(subject.save).to eq(false)
    expect(subject.errors.any?).to eq(true)
    expect(subject.errors.messages.keys.count).to eq(1)
    expect(subject.errors.messages).to have_key(:state)
  end

  it "requires a zip" do
    subject = MarketAddress.new(name: "new address", address: "123 Apple", city: "Holland", state: "MI", market: market)
    expect(subject.save).to eq(false)
    expect(subject.errors.any?).to eq(true)
    expect(subject.errors.messages.keys.count).to eq(1)
    expect(subject.errors.messages).to have_key(:zip)
  end

  it "requires a market" do
    subject = MarketAddress.new(name: "new address", address: "123 Apple", city: "Holland", state: "MI", zip: "49423")
    expect(subject.save).to eq(false)
    expect(subject.errors.any?).to eq(true)
    expect(subject.errors.messages.keys.count).to eq(1)
    expect(subject.errors.messages).to have_key(:market)
  end

  it "does not require default check" do
    subject = MarketAddress.new(name: "new address", address: "123 Apple", city: "Holland", state: "MI", zip: "49423", market: market)
    expect(subject.save).to eq(true)
  end

  it "does not require billing check" do
    subject = MarketAddress.new(name: "new address", address: "123 Apple", city: "Holland", state: "MI", zip: "49423", market: market, billing: true)
    expect(subject.save).to eq(true)
  end

  describe "soft_delete" do
    include_context "soft delete-able models"
    it_behaves_like "a soft deleted model"
  end

end
