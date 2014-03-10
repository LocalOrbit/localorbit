require "spec_helper"

describe "A Market Manager managing Newsletters" do
  let(:market_manager) { create :user, :market_manager }
  let(:market) { market_manager.managed_markets.first }

  before(:each) do
    sign_in_as market_manager
  end

  describe "Adding a newsletter" do
    before do
      # TODO use navigation
      # click_link 'Newsletters'
      visit admin_market_newsletters_path(market)
      click_link 'Add Newsletter'
    end

    context "with valid information" do
      it "creates a newsletter" do
        fill_in "Subject", with: 'Big News'
        fill_in "Header", with: "Some really exciting stuff"
        fill_in "Body", with: "bla bla bla"
        check "Buyers"
        check "Sellers"
        check "Market Managers"
        attach_file 'Image', 'app/assets/images/backgrounds/kale.jpg'
        click_button "Add Newsletter"
        expect(page).to have_content("Big News")
      end
    end

    context "with invalid information" do
      it "creates a newsletter" do
        fill_in "Subject", with: ''
        fill_in "Header", with: ""
        fill_in "Body", with: ""
        click_button "Add Newsletter"
        expect(page).to have_content("Subject can't be blank")
      end
    end
  end

  describe "Editing a newsletter" do
    let!(:newsletter) { create :newsletter, market: market }

    before do
      # TODO use navigation
      # click_link 'Newsletters'
      visit admin_market_newsletters_path(market)
      click_link newsletter.subject
    end

    context "with valid information" do
      it "saves the newsletter" do
        fill_in "Subject", with: 'Big News'
        fill_in "Header", with: "Some really exciting stuff"
        fill_in "Body", with: "bla bla bla"
        attach_file 'Image', 'app/assets/images/backgrounds/kale.jpg'
        click_button "Save Newsletter"
        expect(page).to have_content("Big News")
      end
    end

    context "with invalid information" do
      it "creates a newsletter" do
        fill_in "Subject", with: ''
        fill_in "Header", with: ""
        fill_in "Body", with: ""
        click_button "Save Newsletter"
        expect(page).to have_content("Subject can't be blank")
      end
    end
  end

  describe "Deleting a newsletter" do
    let!(:newsletter) { create :newsletter, market: market }

    before do
      # TODO use navigation
      # click_link 'Newsletters'
      visit admin_market_newsletters_path(market)
    end

    it "deletes the newsletter" do
      expect(page).to have_content(newsletter.subject)
      click_button "Delete"
      expect(page).not_to have_content(newsletter.subject)
    end
  end

end
