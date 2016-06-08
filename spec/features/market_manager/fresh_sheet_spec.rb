require "spec_helper"

feature "A Market Manager sending a weekly Fresh Sheet" do
  let!(:user) { create(:user, :market_manager) }
  let!(:market) { user.managed_markets.first }
  let!(:delivery_schedule) { create(:delivery_schedule, seller_fulfillment_location: create(:market_address), buyer_pickup_location_id: 0, day: 1, buyer_day: 2, buyer_pickup_start: "1:00 PM", buyer_pickup_end: "2:00 PM", market: market) }
  let!(:seller) { create(:organization, :seller, markets: [market]) }
  let!(:product) { create(:product, :sellable, organization: seller) }
  include_context "fresh sheet and newsletter subscription types"
  let!(:fresh_sheet) { fresh_sheet_subscription_type }
  let!(:newsletter) { newsletter_subscription_type }

  # Intentionally not let! changing that will break tests
  let(:buyer_org) { create(:organization, :buyer, markets: [market]) }
  let(:buyer_user) { 
    jack = create(:user, :buyer, organizations: [buyer_org], name: "Jack Stevens")
    jack.subscribe_to(SubscriptionType::Keywords::FreshSheet)
    jack 
  }

  scenario "navigating to the page" do
    switch_to_subdomain(market.subdomain)
    sign_in_as user
    click_link "Marketing"
    click_link "Fresh Sheet"
    expect(page).to have_content("Fresh Sheet")
    expect(page).to have_css("iframe[src='#{preview_admin_fresh_sheet_path}']")
  end

  scenario "selecting a market" do
    create(:market, managers: [user])
    switch_to_main_domain
    sign_in_as(create(:user, :admin))
    visit admin_fresh_sheet_path
    expect(page).to have_content("Please Select a Market")
    click_link market.name
    expect(page).to have_content("Fresh Sheet")
    expect(page).to have_css("iframe[src='#{preview_admin_fresh_sheet_path}']")
  end

  context "signed in" do
    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as user
    end

    context "previewing" do
      scenario "shows a page with the preview in an iframe" do
        visit admin_fresh_sheet_path
        expect(page).to have_content("Fresh Sheet")
        expect(page).to have_css("iframe[src='#{preview_admin_fresh_sheet_path}']")
      end

      scenario "iframe contains to the email preview" do
        visit preview_admin_fresh_sheet_path

        expect(page).to have_content("See what's fresh at #{market.name}")
        delivery = delivery_schedule.next_delivery.decorate
        expect(page).to have_content("#{delivery.buyer_display_date} #{delivery.buyer_time_range}")
      end
    end

    context "adding a custom note" do
      scenario "note is displayed in preview" do
        visit admin_fresh_sheet_path

        click_link "Add Note"

        fill_in "note", with: "Forever Young"
        click_button "Add Note"

        visit preview_admin_fresh_sheet_path
        expect(page).to have_content("Forever Young")
      end


      scenario "note is in sent email" do
        expect_send_fresh_sheet_mail market: market, to: buyer_user.pretty_email, note: "Something Else", unsubscribe_token: buyer_user.unsubscribe_token(subscription_type: fresh_sheet)
        visit admin_fresh_sheet_path

        click_link "Add Note"

        fill_in "note", with: "Forever Young"
        click_button "Add Note"
        fill_in "note", with: "Something Else"

        click_button "Send to Everyone Now"

        expect(page).to have_content("Successfully sent the Fresh Sheet")
        Delayed::Worker.new.work_off
      end

      scenario "note is cleared once email is sent to customers" do
        visit admin_fresh_sheet_path

        click_link "Add Note"

        fill_in "note", with: "Forever Young"
        click_button "Add Note"

        click_button "Send to Everyone Now"

        visit preview_admin_fresh_sheet_path
        expect(page).not_to have_content("Forever Young")
      end
    end

    scenario "sending a test" do
      expect_send_fresh_sheet_mail market: market, to: user.email, note: "", unsubscribe_token: "XYZ987"
      visit admin_fresh_sheet_path
      click_button "Send Test"
      expect(page).to have_content("Successfully sent a test to #{user.email}")
      Delayed::Worker.new.work_off
    end

    scenario "sending a test to a different email" do
      expect_send_fresh_sheet_mail market: market, to: "foo@example.com", note: "", unsubscribe_token: "XYZ987"
      visit admin_fresh_sheet_path
      fill_in "email", with: "foo@example.com"
      click_button "Send Test"
      expect(page).to have_content("Successfully sent a test to foo@example.com")
      Delayed::Worker.new.work_off
    end

    scenario "sending to everyone" do
      expect_send_fresh_sheet_mail market: market, to: buyer_user.pretty_email, note: "", unsubscribe_token: buyer_user.unsubscribe_token(subscription_type: fresh_sheet)
      visit admin_fresh_sheet_path
      click_button "Send to Everyone Now"
      expect(page).to have_content("Successfully sent the Fresh Sheet")
      Delayed::Worker.new.work_off
    end

    scenario "sending to everyone without any buyers" do
      expect(MarketMailer).not_to receive(:fresh_sheet)
      visit admin_fresh_sheet_path
      click_button "Send to Everyone Now"
      expect(page).to have_content("Successfully sent the Fresh Sheet")
      Delayed::Worker.new.work_off
    end
  end
end

feature "an Admin with more then one market sends a weekly Fresh Sheet" do
  let!(:user) { create(:user, :admin) }
  let!(:markets) { create_list(:market, 2) }
  let!(:delivery_schedule) { create(:delivery_schedule, market: markets.first) }
  let!(:seller) { create(:organization, :seller, markets: [markets.first]) }
  let!(:product) { create(:product, :sellable, organization: seller) }

  before do
    user.markets << markets
  end

  scenario "selecting a market" do
    switch_to_main_domain
    sign_in_as(user)

    visit admin_fresh_sheet_path
    expect(page).to have_content("Please Select a Market")
    click_link markets.first.name
    expect(page).to have_content("Fresh Sheet")
    expect(page).to have_css("iframe[src='#{preview_admin_fresh_sheet_path}']")
  end

  #
  # HELPERS
  #

end
