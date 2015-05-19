require "spec_helper"

describe "Managing Markets" do
  let(:add_market_link_name) { "Add Market" }

  describe "as a market manager" do
    let!(:market1) { create(:market) }
    let!(:market2) { create(:market) }
    let!(:user) { create(:user, role: "user", managed_markets: [market1, market2]) }

    before do
      switch_to_subdomain market1.subdomain
      sign_in_as user
    end

    context "I can see the details for each of my markets" do
      it "through the market listing" do
        visit "/admin/markets"

        click_link market1.name

        expect(page).to have_text(market1.name)
        expect(page).to_not have_text(market2.name)
      end

      it "by navigating directly to the market" do
        visit "/admin/markets/#{market1.id}"

        expect(page).to have_text(market1.name)
        expect(page).to_not have_text(market2.name)

        visit "/admin/markets/#{market1.id}"

        expect(page).to have_text(market1.name)
        expect(page).to_not have_text(market2.name)
      end
    end

    it "I can modify a market" do
      visit "/admin/markets"
      click_link market1.name

      expect(find_field("market_contact_name").value).to eq("Jill Smith")

      fill_in "Contact name", with: "Jane Smith"

      click_button "Update Market"

      expect(page).to have_text("Market Information")
      expect(find_field("market_contact_name").value).to eq("Jane Smith")
    end

    it "I cannot activate a market" do
      market1.update_attribute(:active, true)
      visit "/admin/markets/#{market1.id}"
      expect(page).not_to have_content("Deactivate")
    end

    it "I cannot deactivate a market" do
      visit "/admin/markets/#{market1.id}"
      expect(page).not_to have_content("Deactivate")
    end

    it "can not change a markets plan" do
      visit admin_market_path(market1)

      expect(page).to_not have_field("Plan")
    end

    it "I cannot see payment options" do
      visit admin_market_path(market1)

      expect(page).to_not have_content("Allowed payment methods")
      expect(page).to_not have_content("Default organization payment methods")

      expect(page).to_not have_content("Allow purchase orders")
      expect(page).to_not have_content("Allow credit cards")
      expect(page).to_not have_content("Allow ACH")
    end

    it "I can not add a market" do
      visit "/admin/markets"

      expect(page).to_not have_text(add_market_link_name)

      visit new_admin_market_path

      expect(page).to have_text("page you were looking for doesn't exist")
    end

    describe "with additional markets" do
      let!(:market3) { create(:market) }

      it "I do not see markets I am not managing in my list" do
        visit "/admin/markets"

        expect(page).to_not have_text(market3.name)
      end

      it "I can not see the details for a market I am not managing" do
        visit admin_market_path(market3)

        expect(page).to have_text("page you were looking for doesn't exist")
      end

      it "I can not modify a market I am not managing" do
        visit admin_market_path(market3)

        expect(page).to have_text("page you were looking for doesn't exist")
      end
    end
  end

  describe "as an admin" do
    let!(:user) { create(:user, :admin) }
    let!(:market) { create(:market, name: "A Market", subdomain: "not-c", contact_name: "B Name", active: true) }

    before :each do
      switch_to_subdomain market.subdomain
      sign_in_as user
    end

    it "can see a list of markets" do
      @market2 = create(:market)
      visit "/admin/markets"

      expect(page).to have_text("Markets")
      expect(page).to have_text(market.name)
      expect(page).to have_text(@market2.name)
    end

    it "can see a list of markets as a CSV" do
      @market2 = create(:market)
      visit "/admin/markets"
      html_headers = page.all("th").map(&:text).select {|header| header != "Actions" }

      click_link "Export CSV"

      csv_headers = CSV.parse(page.body).first

      expect(html_headers).to eq(csv_headers)

      expect(page).to have_text(market.name)
      expect(page).to have_text(@market2.name)
    end

    it "can toggle a market's active status" do
      visit admin_markets_path

      click_link "Deactivate"
      expect(page).to have_content("Updated #{market.name}")

      click_link("Activate")
      expect(page).to have_content("Updated #{market.name}")
    end

    context "sorting", :js do
      let!(:market_b) { create(:market, name: "B Market", subdomain: "not-a", contact_name: "C Name") }
      let!(:market_c) { create(:market, name: "C Market", subdomain: "not-b", contact_name: "A Name") }

      before do
        visit admin_markets_path
      end

      context "by name" do
        it "ascending" do
          click_header("name")

          first = Dom::Admin::MarketRow.first
          expect(first.name).to have_content(market.name)
        end

        it "descending" do
          click_header_twice("name")

          first = Dom::Admin::MarketRow.first
          expect(first.name).to have_content(market_c.name)
        end
      end

      context "by subdomain" do
        it "ascending" do
          click_header("subdomain")

          first = Dom::Admin::MarketRow.first
          expect(first.name).to have_content(market_b.name)
        end

        it "descending" do
          click_header_twice("subdomain")

          first = Dom::Admin::MarketRow.first
          expect(first.name).to have_content(market.name)
        end
      end

      context "by contact name" do
        it "ascending" do
          click_header("contact")

          first = Dom::Admin::MarketRow.first
          expect(first.name).to have_content(market_c.name)
        end

        it "descending" do
          click_header_twice("contact")

          first = Dom::Admin::MarketRow.first
          expect(first.name).to have_content(market_b.name)
        end
      end
    end

    it "can see details for a single market" do
      @market2 = create(:market)

      visit "/admin/markets"

      click_link market.name

      expect(page).to have_text(market.name)
      expect(page).to_not have_text(@market2.name)
    end

    it "can add a market", :vcr do
      visit "/admin/markets"

      click_link add_market_link_name

      fill_in "Name",          with: "Holland Farmers"
      fill_in "Subdomain",     with: "holland-farmers"
      fill_in "Tagline",       with: "Dutch People, Dutch Prices!"
      select "(GMT-05:00) Eastern Time (US & Canada)", from: "Time zone"
      fill_in "Contact name",  with: "Jill Smith"
      fill_in "Contact email", with: "jill@smith.com"
      fill_in "Contact phone", with: "616-222-2222"
      fill_in "Facebook",      with: "https://www.facebook.com/hollandfarmers"
      fill_in "Twitter",       with: "@hollandfarmers"
      fill_in "Profile",       with: "Some interesting info about Holland Farmers"
      fill_in "Policies",      with: "Something no one will pay attention to"
      attach_file "Logo", "app/assets/images/logo.png"
      attach_file "Photo", "app/assets/images/backgrounds/lentils.jpg"

      click_button "Add Market"

      expect(find_field("Name").value).to eq("Holland Farmers")
      expect(find_field("Tagline").value).to eq("Dutch People, Dutch Prices!")
      expect(find_field("Contact name").value).to eq("Jill Smith")
      expect(find_field("Twitter").value).to eq("hollandfarmers")

      market = Market.find_by_name('Holland Farmers')

      # See we got setup w Stripe:
      expect(market.balanced_customer_uri).to be(nil), "should no longer be creating Balanced objects"
      expect(market.stripe_account_id).to be
      expect(market.stripe_customer_id).to be

      stripe_account = Stripe::Account.retrieve(market.stripe_account_id)
      expect(stripe_account.business_name).to eq market.name
      expect(stripe_account.debit_negative_balances).to be true
      expect(stripe_account.metadata['lo.market_id']).to eq market.id.to_s

      stripe_customer = Stripe::Customer.retrieve(market.stripe_customer_id)
      expect(stripe_customer).to be
      expect(stripe_customer.description).to eq market.name
    end

    describe "adding a market without valid information" do
      it "shows an error message" do
        visit "/admin/markets"

        click_link add_market_link_name

        fill_in "Name", with: ""
        click_button "Add Market"
        expect(page).to have_content("Could not create market")
        expect(page).to have_content("Name can't be blank")
      end
    end

    it "can modify a market" do
      visit "/admin/markets"
      click_link market.name

      expect(find_field("market_contact_name").value).to eq("B Name")

      fill_in "Contact name", with: "Jane Smith"

      click_button "Update Market"

      expect(page).to have_text("Market Information")
      expect(find_field("market_contact_name").value).to eq("Jane Smith")
    end

    it "can change a markets plan" do
      new_plan = create(:plan)
      visit admin_market_fees_path(market)

      expect(find_field("Plan").value).to eq(market.plan_id.to_s)

      select new_plan.name, from: "Plan"
      click_button "Update Fees"

      expect(find_field("Plan").value).to eq(new_plan.id.to_s)
    end

    it "can set the auto-activation flag for organization registrations" do
      visit admin_market_path(market)

      expect(find_field("Auto-activate organizations")).to_not be_checked

      check "Auto-activate organizations"
      click_button "Update Market"

      expect(find_field("Auto-activate organizations")).to be_checked
    end

    context "payment options" do
      before do
        visit admin_market_path(market)
      end

      it "can see payment options" do
        expect(page).to have_content("Allowed payment methods")
        expect(page).to have_content("Default organization payment methods")

        expect(page).to have_content("Allow purchase orders")
        expect(page).to have_content("Allow credit cards")
        expect(page).to have_content("Allow ACH")
      end

      it "can modify payment options" do
        within("#allowed-payment-options") do
          uncheck "Allow purchase orders"
          uncheck "Allow ACH"
        end

        within("#default-payment-options") do
          check "Allow purchase orders"
          uncheck "Allow ACH"
        end

        click_button "Update Market"

        expect(find("#market_allow_purchase_orders")).to_not be_checked
        expect(find("#market_allow_credit_cards")).to be_checked
        expect(find("#market_allow_ach")).to_not be_checked

        expect(find("#market_default_allow_purchase_orders")).to be_checked
        expect(find("#market_default_allow_credit_cards")).to be_checked
        expect(find("#market_default_allow_ach")).to_not be_checked
      end

      it "requires at lease one payment method" do
        within("#allowed-payment-options") do
          uncheck "Allow purchase orders"
          uncheck "Allow credit cards"
          uncheck "Allow ACH"
        end

        click_button "Update Market"

        expect(page).to have_content("At least one payment method is required for the market")
      end
    end

    describe "modifying a market without valid information", js: true do
      it "shows an error message" do
        visit "/admin/markets"
        click_link market.name

        fill_in "Name", with: ""
        click_button "Update Market"
        expect(page).to have_content("Could not update market")
        expect(page).to have_content("Name can't be blank")

        within("h1") do
          expect(page).to have_content(market.name)
        end
      end
    end

    it "can mark an active market as inactive" do
      visit "/admin/markets/#{market.id}"

      expect(find(:xpath, "//input[@id='market_active']").value).to eq("false")

      click_button "Deactivate"

      expect(find(:xpath, "//input[@id='market_active']").value).to eq("true")
    end

    it "can mark an inactive market as active" do
      market.update_attributes(active: false)

      visit "/admin/markets/#{market.id}"

      expect(find(:xpath, "//input[@id='market_active']").value).to eq("true")
      click_button "Activate"

      expect(find(:xpath, "//input[@id='market_active']").value).to eq("false")
    end

    it "can update the market fee structure" do
      visit "/admin/markets/#{market.id}"
      click_link "Fees"

      fill_in "Local Orbit % paid by Seller",   with: "2.0"
      fill_in "Local Orbit % paid by market",   with: "4.0"
      fill_in "Market % paid by Seller",        with: "3.0"
      fill_in "Credit Card fee paid by Seller", with: "2.5"
      fill_in "Credit Card fee paid by market", with: "4.5"
      fill_in "ACH fee paid by Seller",         with: "3.5"
      fill_in "ACH fee paid by market",         with: "5.5"
      fill_in "ACH fee cap",                    with: "10.00"
      fill_in "PO Payment Terms",               with: "18"

      click_button "Update Fees"

      expect(page).to have_content("#{market.name} fees successfully updated")
      expect(find_field("Local Orbit % paid by Seller").value).to eq("2.000")
      expect(find_field("Local Orbit % paid by market").value).to eq("4.000")
      expect(find_field("Market % paid by Seller").value).to eq("3.000")
      expect(find_field("Credit Card fee paid by Seller").value).to eq("2.500")
      expect(find_field("Credit Card fee paid by market").value).to eq("4.500")
      expect(find_field("ACH fee paid by Seller").value).to eq("3.500")
      expect(find_field("ACH fee paid by market").value).to eq("5.500")
      expect(find_field("ACH fee cap").value).to eq("10.00")
      expect(find_field("PO Payment Terms").value).to eq("18")
    end
  end
end
