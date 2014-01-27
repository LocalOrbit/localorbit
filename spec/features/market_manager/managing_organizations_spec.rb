require "spec_helper"

describe "A Market Manager" do
  let(:market_manager) { create :user, :market_manager }
  let(:market) { market_manager.managed_markets.first }
  let(:market2) { create(:market) }

  before(:each) do
    sign_in_as market_manager
  end

  describe "Adding an organization" do
    it "with valid information" do
      click_link 'Organizations'
      click_link 'Add Organization'

      fill_in 'Name', with: 'Famous Farm'
      check 'Can sell product'
      click_button 'Add Organization'

      expect(page).to have_content('Famous Farm has been created')
    end

    context "when the market manager manages multiple markets" do

      before do
        market_manager.managed_markets << market2
      end

      it "with valid information" do
        click_link 'Organizations'
        click_link 'Add Organization'

        fill_in 'Name', with: 'Famous Farm'
        select market2.name, from: "Market"
        check 'Can sell product'
        click_button 'Add Organization'

        expect(page).to have_content("Famous Farm has been created")
      end

      context "without selecting a market" do
        it "doesn't add the new organization" do
          click_link 'Organizations'
          click_link 'Add Organization'
          fill_in 'Name', with: 'Dairy Farms Co-op'
          click_button 'Add Organization'

          expect(page).to have_content("Markets can't be blank")
        end
      end
    end

    context "with a blank name" do
      it "doesn't add the new organization" do
        click_link 'Organizations'
        click_link 'Add Organization'

        fill_in 'Name', with: ''
        click_button 'Add Organization'

        expect(page).to have_content("Name can't be blank")
      end
    end
  end

  describe "Editing an organization" do
    let(:organization) { create(:organization, name: "Fresh Pumpkin Patch") }

    before do
      market.organizations << organization
    end

    it "allows updating all attributes" do
      click_link 'Organizations'
      click_link "Fresh Pumpkin Patch"
      click_link "Edit Organization"

      fill_in "Name", with: "SXSW Farmette"
      uncheck "Can sell product"
      click_button "Save Organization"

      expect(page).to have_content("Saved SXSW Farmette")
      expect(page).to have_content("Name SXSW Farmette")
      expect(page).to have_content("Can sell products? false")
    end

    it "does not allow updates with a blank organization name" do
      click_link 'Organizations'
      click_link "Fresh Pumpkin Patch"
      click_link "Edit Organization"

      fill_in "Name", with: ""
      click_button "Save Organization"

      expect(page).to have_content("Name can't be blank")
    end

    describe "when a market manager has multiple markets" do
      before do
        market_manager.markets << market2
      end

      it "cannot change the market of an organizaiton" do
        click_link 'Organizations'
        click_link "Fresh Pumpkin Patch"
        click_link "Edit Organization"

        expect(page).to_not have_selector("organization_market_ids")
      end
    end

  end

  describe "Inviting a member to an org" do
    let(:org) { create(:organization, name: "Holland Farms")}

    before do
      market.organizations << org
    end

    context "when the user is not yet a member" do
      it "sends an email to a recipient inviting them to join an organization" do
        click_link 'Organizations'
        click_link "Holland Farms"
        click_link "Users"

        within("#new_user") do
          fill_in "Email", with: "susan@example.com"
          click_button "Invite a new member"
        end

        expect(page).to have_content("Sent invitation to susan@example.com")

        open_last_email_for "susan@example.com"
        expect(current_email).to have_subject("You have been invited to Local Orbit")
      end
    end

    context "when the user is an active member of an organization" do
      let(:user) { create(:user, :admin) }
      before do
        org.users << user
      end

      it "show an error message" do
        click_link 'Organizations'
        click_link "Holland Farms"
        click_link "Users"

        within("#new_user") do
          fill_in "Email", with: user.email
          click_button "Invite a new member"
        end

        expect(page).to have_content("You have already added this user")
      end
    end

    context "when no email has been entered" do
      it "show an error message" do
        click_link 'Organizations'
        click_link "Holland Farms"
        click_link "Users"

        within("#new_user") do
          fill_in "Email", with:""
          click_button "Invite a new member"
        end

        expect(page).to have_content("Email can't be blank")
      end
    end

    context "when an invalid email address has been entered" do
      it "show an error message" do
        click_link 'Organizations'
        click_link "Holland Farms"
        click_link "Users"

        within("#new_user") do
          fill_in "Email", with:"asdfasdfasdfasdfasd"
          click_button "Invite a new member"
        end

        expect(page).to have_content("Email is invalid")
      end
    end

  end
end
