require 'spec_helper'

describe Organization do

  it 'requires a name' do
    org = Organization.new
    expect(org).to_not be_valid
    expect(org).to have(1).error_on(:name)
  end

  describe "Scopes:" do
    describe "#selling" do
      let!(:seller) { create(:organization, :seller) }
      let!(:buyer) { create(:organization, :buyer) }

      it "only returns organizations that can sell" do
        result = Organization.selling.all
        expect(result.count).to eql(1)
        expect(result.first).to eql(seller)
      end
    end
  end
end
