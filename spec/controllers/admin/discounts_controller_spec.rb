require "spec_helper"

describe Admin::DiscountsController do
  let(:mm)     { create(:user, :market_manager) }
  let(:market) {mm.managed_markets.first}
  # let(:controller) {Admin::DiscountsController.new}

  before do
    switch_to_subdomain market.subdomain
    sign_in mm
  end

  describe "#find_markets" do
    it "gracefully handles markets without plans" do
      market = mm.managed_markets.first
      Plan.delete market.plan
      expect(controller.find_markets).to eq []
    end
  end

end
