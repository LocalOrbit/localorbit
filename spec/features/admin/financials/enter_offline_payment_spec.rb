require "spec_helper"

describe "Enter Offline Payment" do
  let!(:market) { create(:market) }
  let!(:seller) { create(:organization, :seller, markets: [market]) }
  let!(:buyer)  { create(:organization, :buyer, markets: [market]) }

  let(:user)    { create(:user) }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
  end

  context "as an admin" do
    let(:user) { create(:user, :admin) }

    it "does show the button to enter an offline payment" do
      visit admin_financials_receipts_path

      expect(page).to have_content("Enter Offline Payment")
    end

    it "saves an offline payment for service fee" do
      visit admin_financials_offline_payment_path
      expect(page).to have_content("Enter Offline Payment")

      select market.name, from: "payment_payer_id"
      fill_in "Payment Amount", with: "250.00"
      select "Service Fee", from: "payment_payment_type"
      click_button "Save Payment"

      expect(page).to have_content("Offline payment successful")

      visit admin_financials_payments_path
      expect(page).to have_content("Service Fee")
      expect(page).to have_content("$250.00")
    end

    it "displays errors upon payment failure" do
      visit admin_financials_offline_payment_path
      expect(page).to have_content("Enter Offline Payment")

      select market.name, from: "payment_payer_id"
      fill_in "Payment Amount", with: "bad"
      select "Service Fee", from: "payment_payment_type"
      click_button "Save Payment"

      expect(page).to have_content("Enter Offline Payment")
      expect(page).to have_content("Offline payment error")
    end
  end

  context "as a market manager" do
    let(:user) { create(:user, managed_markets: [market]) }

    it "does not show the button to enter an offline payment" do
      visit admin_financials_receipts_path

      expect(page).to_not have_content("Enter Offline Payment")
    end
  end

  context "as a seller" do
    let!(:user)    { create(:user) }
    it "does not show the button to enter an offline payment" do
      visit admin_financials_receipts_path

      expect(page).to_not have_content("Enter Offline Payment")
    end
  end
end
