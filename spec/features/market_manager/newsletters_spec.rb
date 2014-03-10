require "spec_helper"

describe "A Market Manager managing Newsletters" do
  let(:market_manager) { create :user, :market_manager }
  let(:market) { market_manager.managed_markets.first }

  before(:each) do
    sign_in_as market_manager
  end

  describe "Adding a newsletter" do
    context "with valid information" do
      before do
        # TODO use navigation
        # click_link 'Newsletters'
        visit admin_market_newsletters_path(market)
        click_link 'Add Newsletter'
      end

      it "creates a newsletter" do
        fill_in "Subject", with: 'Big News'
        fill_in "Header", with: "Some really exciting stuff"
        fill_in "Body", with: "bla bla bla"
        attach_file 'Image', 'app/assets/images/backgrounds/kale.jpg'
        click_button "Add Newsletter"
        expect(page).to have_content("Big News")
      end
    end
  end
end
