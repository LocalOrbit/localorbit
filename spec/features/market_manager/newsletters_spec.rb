require "spec_helper"

describe "A Market Manager managing Newsletters" do
  let(:market_manager) { create :user, :market_manager, send_newsletter: true }
  let(:market) { market_manager.managed_markets.first }

  before(:each) do
    switch_to_subdomain(market.subdomain)
    sign_in_as market_manager
  end

  it "getting there" do
    click_link "Marketing"
    click_link "Newsletters"
    within "h1" do
      expect(page).to have_content('Newsletters')
    end
  end

  describe "Adding a newsletter" do
    before do
      visit admin_newsletters_path
      click_link 'Add Newsletter'
    end

    context "with valid information" do
      it "creates a newsletter" do
        fill_in "Subject", with: 'Big News'
        fill_in "Headline", with: "Some really exciting stuff"
        fill_in "Body", with: "bla bla bla"
        check "Buyers"
        check "Sellers"
        check "Market Managers"
        attach_file 'Image', 'app/assets/images/logo.png'
        click_button "Add Newsletter"
        expect(page).to have_content("Big News")
      end
    end

    context "with invalid information" do
      it "creates a newsletter" do
        fill_in "Subject", with: ''
        fill_in "Headline", with: ""
        fill_in "Body", with: ""
        click_button "Add Newsletter"
        expect(page).to have_content("Subject can't be blank")
      end
    end
  end

  describe "Editing a newsletter" do
    let!(:newsletter) { create :newsletter, market: market }

    before do
      visit admin_newsletters_path
      click_link newsletter.subject
    end

    context "with valid information" do
      it "saves the newsletter" do
        fill_in "Subject", with: 'Big News'
        fill_in "Headline", with: "Some really exciting stuff"
        fill_in "Body", with: "bla bla bla"
        attach_file 'Image', 'app/assets/images/logo.png'
        click_button "Save Newsletter"
        expect(page).to have_content("Big News")
      end
    end

    context "with invalid information" do
      it "creates a newsletter" do
        fill_in "Subject", with: ''
        fill_in "Headline", with: ""
        fill_in "Body", with: ""
        click_button "Save Newsletter"
        expect(page).to have_content("Subject can't be blank")
      end
    end
  end

  describe "Deleting a newsletter" do
    let!(:newsletter) { create :newsletter, market: market }

    before do
      visit admin_newsletters_path
    end

    it "deletes the newsletter" do
      expect(page).to have_content(newsletter.subject)
      click_link "Delete"
      expect(page).not_to have_content(newsletter.subject)
    end
  end

  describe "Sending" do
    let!(:newsletter) { create :newsletter, market: market }

    before do
      visit admin_newsletter_path(newsletter)
    end

    describe "a test" do
      it "sends a test" do
        expect(MarketMailer).to receive(:newsletter).with(newsletter, market, market_manager.email).and_return(double(:mailer, deliver: true))
        click_button "Send Test"
        expect(page).to have_content("Successfully sent a test to #{market_manager.email}")
      end

      it "allows sending a test to a different email" do
        expect(MarketMailer).to receive(:newsletter).with(newsletter, market, "foo@example.com").and_return(double(:mailer, deliver: true))
        fill_in "email", with: "foo@example.com"
        click_button "Send Test"
        expect(page).to have_content("Successfully sent a test to foo@example.com")
      end
    end

    describe "to groups" do
      it "sends to specific groups" do
        email = "#{market_manager.name} <#{market_manager.email}>"
        expect(MarketMailer).to receive(:newsletter).with(newsletter, market, email).and_return(double(:mailer, deliver: true))
        check "Market Managers"
        click_button "Send Now"
        expect(page).to have_content("Successfully sent this Newsletter")
      end
    end
  end
end
