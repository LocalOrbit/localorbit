require "spec_helper"

describe "A Market Manager managing Newsletters" do
  let!(:newsletter_type) { create(:subscription_type, :newsletter) }
  let(:market_manager) { create :user, :market_manager, subscription_types: [newsletter_type] }
  let(:market) { market_manager.managed_markets.first }

  before(:each) do
    switch_to_subdomain(market.subdomain)
    sign_in_as market_manager
  end

  it "getting there" do
    click_link "Marketing"
    click_link "Newsletters"
    within "h1" do
      expect(page).to have_content("Newsletters")
    end
  end

  describe "Adding a newsletter" do
    before do
      visit admin_newsletters_path
      click_link "Add Newsletter"
    end

=begin
    context "with valid information" do
      it "creates a newsletter" do
        fill_in "Subject", with: "Big News"
        fill_in "Headline", with: "Some really exciting stuff"
        find("#newsletter_body",:visible=>false).set "bla bla bla"
        #fill_in "body", with: "bla bla bla"
        check "Buyers"
        check "Suppliers"
        check "Manager"
        attach_file "Image", "app/assets/images/logo.png"
        click_button "Add Newsletter"
        expect(page).to have_content("Big News")
      end
    end

    context "with invalid information" do
      it "creates a newsletter" do
        fill_in "Subject", with: ""
        fill_in "Headline", with: ""
        find("#newsletter_body",:visible=>false).set ""
        #fill_in "body", with: ""
        click_button "Add Newsletter"
        expect(page).to have_content("Subject can't be blank")
      end
    end
=end
  end

  describe "Editing a newsletter" do
    let!(:newsletter) { create :newsletter, market: market }

    before do
      visit admin_newsletters_path
      click_link newsletter.subject
    end

=begin
    context "with valid information" do
      it "saves the newsletter" do
        fill_in "Subject", with: "Big News"
        fill_in "Headline", with: "Some really exciting stuff"
        find("#newsletter_body",:visible=>false).set "bla bla bla"
        #fill_in "body", with: "bla bla bla"
        attach_file "Image", "app/assets/images/logo.png"
        click_button "Save Newsletter"
        expect(page).to have_content("Big News")
      end
    end

    context "with invalid information" do
      it "creates a newsletter" do
        fill_in "Subject", with: ""
        fill_in "Headline", with: ""
        find("#newsletter_body",:visible=>false).set ""
        #fill_in "body", with: ""
        click_button "Save Newsletter"
        expect(page).to have_content("Subject can't be blank")
      end
    end
=end
  end


  describe "Deleting a newsletter" do
    let!(:newsletter) { create :newsletter, market: market }

    before do
      visit admin_newsletters_path
    end

    it "deletes the newsletter" do
      expect(page).to_not have_content("No Newsletters")
      expect(page).to have_content(newsletter.subject)
      click_link "Delete"
      expect(page).not_to have_content(newsletter.subject)
      expect(page).to have_content("No Newsletters")
    end
  end

  describe "Sending" do
    let!(:newsletter) { create :newsletter, market: market, buyers: false, sellers: false, market_managers: false }
    let(:token) { "XYZ-test-unsub-newsletter-0986" }

    before do
      visit admin_newsletter_path(newsletter)
    end

    describe "a test" do
      it "sends a test" do
        expect_send_newsletter_mail(newsletter:newsletter, market:market, to:market_manager.email,unsubscribe_token:token)
        click_button "Send Test"
        expect(page).to have_content("Successfully sent a test to #{market_manager.email}")
      end

      it "allows sending a test to a different email" do
        expect_send_newsletter_mail(newsletter:newsletter, market:market, to:"foo@example.com",unsubscribe_token:token)
        fill_in "email", with: "foo@example.com"
        click_button "Send Test"
        expect(page).to have_content("Successfully sent a test to foo@example.com")
      end
    end

    describe "to groups" do
      it "sends to Manager" do
        newsletter.market_managers=true
        mmtoken = market_manager.unsubscribe_token(subscription_type: SubscriptionType.find_by(keyword:SubscriptionType::Keywords::Newsletter))
        expect_send_newsletter_mail(newsletter:newsletter, market:market, to:market_manager.pretty_email,unsubscribe_token:mmtoken)
        check "Manager"
        click_button "Send Now"
        expect(page).to have_content("Successfully sent this Newsletter")
      end
    end
  end
end
