require 'spec_helper'

describe SellerOverview do
  let(:seller) { create(:organization) }

  subject { SellerOverview.new(seller: seller) }

  it "requires a seller" do
    expect {
      SellerOverview.new(seller: nil)
    }.to raise_error
  end
end
