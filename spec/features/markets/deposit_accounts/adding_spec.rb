require "spec_helper"

feature "Adding deposit account to a market", :js, :vcr do
  let!(:market) { create(:market, name: "Neomarket", 
                         payment_provider: 'stripe',
                         contact_email: "misteranderson@example.com") 
  }

  before do
    switch_to_subdomain(market.subdomain)
  end

  scenario "as an admin" do
    sign_in_as(create(:user, :admin))
    add_and_remove_a_deposit_account
  end

  scenario "as a market manager" do
    sign_in_as(create(:user, :market_manager, managed_markets: [market]))
    # sign_in_as(create(:user, :admin))
    add_and_remove_a_deposit_account
  end

  def add_and_remove_a_deposit_account
    visit admin_market_path(market)
    click_on "Deposit Accounts"
    click_on "Add Deposit Account"


    # Checking should be preselected:
    expect(find_field("Account Type").value).to eq "checking"

    fill_in "Name", with: "My Dep Acct."
    fill_in "Routing Number", with: "110000000"
    fill_in "Account Number", with: "000123456789"
    fill_in "Notes", with: "Let's get to it"

    click_on "Save This Deposit Account"
    
    expect(page).to have_content("Successfully added deposit account")

    bank_account = Dom::BankAccount.first
    expect(bank_account.bank_name).to eq("STRIPE TEST BANK")
    expect(bank_account.name).to eq("My Dep Acct.")
    expect(bank_account.account_number).to eq("******6789")
    expect(bank_account.account_type).to eq("Checking")

    # NOTICE there's no Add Deposit Account button
    expect(page).not_to have_content("Add Deposit Account")

    # DELETE the account
    bank_account.click_remove_link

    expect(page).to have_content("Successfully removed deposit account")
    expect(Dom::BankAccount.count).to eql(0)

    # NOTICE the Add Deposit Account button has returned
    expect(page).to have_content("Add Deposit Account")

  end

  # scenario "as a market manager" do
  #   switch_to_subdomain(market.subdomain)
  #   sign_in_as(create(:user, managed_markets: [market]))
  #
  #   visit new_admin_market_bank_account_path(market)
  #
  #   select "Checking", from: "provider_account_type"
  #
  #   fill_in "EIN", with: "20-1234567"
  #   fill_in "Full Legal Name", with: "John Patrick Doe"
  #   select "Sep", from: "representative_dob_month"
  #   select "17", from: "representative_dob_day"
  #   select "1990", from: "representative_dob_year"
  #
  #   fill_in "Last 4 of SSN", with: "1234"
  #   fill_in "Street Address (Personal)", with: "6789 Fake Dr"
  #   fill_in "Zip Code (Personal)", with: "12345"
  #
  #   fill_in "Name", with: "Market Bank Account"
  #   select("Checking", from: "Account Type")
  #   fill_in "Routing Number", with: "021000021"
  #   fill_in "Account Number", with: "9900000002"
  #
  #   click_button "Save"
  #
  #   expect(page).to have_content("Successfully added a payment method")
  #
  #   bank_account = Dom::BankAccount.first
  #   expect(bank_account.bank_name).to eq("JPMORGAN CHASE BANK")
  #   expect(bank_account.name).to eq("Market Bank Account")
  #   expect(bank_account.account_number).to eq("******0002")
  #   expect(bank_account.account_type).to eq("Checking")
  #
  #   expect(market.reload).to be_balanced_underwritten
  # end

  # context "when market payment provider is not Stripe" do
  #   before { market.update(payment_provider: 'balanced') }
  #
  #   it "the Deposit Accounts tab is hiding" do
  #     switch_to_subdomain(market.subdomain)
  #     sign_in_as(create(:user, :admin))
  #
  #     visit admin_market_path(market)
  #     expect(page).not_to have_selector('a', text: 'Deposit Accounts')
  #   end
  # end

end
