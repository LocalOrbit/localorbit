require "spec_helper"

feature "Market Manager adds an organization" do
  let(:market) { FactoryGirl.create(:market) }
  let(:market_manager){ FactoryGirl.create(:user, :market_manager, market: market) }

  scenario "basic organization" do
    sign_in_as FactoryGirl.create(:user, role: "market_manager")
  end
end
