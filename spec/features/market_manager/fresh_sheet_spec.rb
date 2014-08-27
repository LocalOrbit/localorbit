require "spec_helper"

feature "A Market Manager sending a weekly Fresh Sheet" do
  let!(:user) { create(:user, :market_manager) }
  let!(:market) { user.managed_markets.first }
  let!(:delivery_schedule) { create(:delivery_schedule, market: market) }
  let!(:seller) { create(:organization, :seller, markets: [market]) }
  let!(:product) { create(:product, :sellable, organization: seller) }

  # Intentionally not let! changing that will break tests
  let(:buyer_org) { create(:organization, :buyer, markets: [market]) }
  let(:buyer_user) { create(:user, organizations: [buyer_org], name: "Jack Stevens") }

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
        expect(MarketMailer).to receive(:fresh_sheet).with(market.id, "\"Jack Stevens\" <#{buyer_user.email}>", "Something Else").and_return(double(:mailer, deliver: true))
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
      expect(MarketMailer).to receive(:fresh_sheet).with(market.id, user.email, "").and_return(double(:mailer, deliver: true))
      visit admin_fresh_sheet_path
      click_button "Send Test"
      expect(page).to have_content("Successfully sent a test to #{user.email}")
      Delayed::Worker.new.work_off
    end

    scenario "sending a test to a different email" do
      expect(MarketMailer).to receive(:fresh_sheet).with(market.id, "foo@example.com", "").and_return(double(:mailer, deliver: true))
      visit admin_fresh_sheet_path
      fill_in "email", with: "foo@example.com"
      click_button "Send Test"
      expect(page).to have_content("Successfully sent a test to foo@example.com")
      Delayed::Worker.new.work_off
    end

    scenario "sending to everyone" do
      expect(MarketMailer).to receive(:fresh_sheet).with(market.id, "\"Jack Stevens\" <#{buyer_user.email}>", "").and_return(double(:mailer, deliver: true))
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
end
