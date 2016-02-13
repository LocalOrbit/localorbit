require 'spec_helper'

describe FreshSheet, :type => :model do
  let(:user) { create(:user) }
  let(:market_org) {create(:organization)}
  let(:market) { create(:market, organization: market_org) }
  let(:note) { create(:market) }

  subject { create(:fresh_sheet, user: user, market: market, note: note) }

  it "has user, market and note" do
    expect(subject).to be
    expect(subject.market).to eq(market)
    expect(subject.user).to eq(user)
  end

end
