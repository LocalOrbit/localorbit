require "spec_helper"

describe "Register" do
  context "a new organization for a market" do
    let!(:manager) { create(:user, email: "fake@example.com") }

    context "automatically activated" do
      let!(:market) { create(:market, managers: [manager], auto_activate_organizations: true) }

      context "happy path", js: true do
        before do
          switch_to_subdomain market.subdomain
          visit root_path

          click_link "Request an Account"

          expect(page).to have_content("Registration: Step One")

          fill_in "Organization Name", with: "Collective Idea"
          fill_in "Contact Name", with: "Daniel Morrison"
          fill_in "Contact Email", with: "daniel@collectiveidea.com"
          fill_in "Password", with: "password1"
          fill_in "Retype Password", with: "password1"

          fill_in "Address Label", with: "Main Location"
          fill_in "Address", with: "44 E. 8th St"
          fill_in "City", with: "Holland"
          select "Michigan", from: "State"
          fill_in "Postal Code", with: "49423"
          fill_in "Phone", with: "616-555-1963"

          expect(page).not_to have_content("Local Orbit User Agreement")
          check "registration_terms_of_service"

          expect(page).to have_content("I have read the Terms of Service")
          find("button.read-terms").trigger("click")

          click_button "Sign Up"
        end

        it "creates a new organization" do
          expect(page).to have_content("Registration: Step Two")
          expect(page).to have_content("daniel@collectiveidea.com")

          expect(Organization.count).to eql(1)
          expect(Organization.last.name).to eql("Collective Idea")
          expect(Organization.last.active).to eql(true)
          expect(Organization.last.can_sell?).to eql(false)
          expect(Organization.last.markets).not_to be_empty
        end

        it 'sends a confirmation email' do
          open_email("daniel@collectiveidea.com")
          expect(current_email.body).to have_content("Verify Email Address")
        end

        # it 'sends the market managers a notification' do
        #   open_email(manager.email)
        #   expect(current_email.body).to have_content("A new organization has registered for your market!")
        # end
      end

      context "happy path with an existing email" do
        let!(:user) { create(:user) }

        before do
          switch_to_subdomain market.subdomain
          visit root_path

          click_link "Request an Account"

          expect(page).to have_content("Registration: Step One")

          fill_in "Organization Name", with: "Collective Idea"
          fill_in "Contact Name", with: "Daniel Morrison"
          fill_in "Contact Email", with: user.email
          fill_in "Password", with: "password1"
          fill_in "Retype Password", with: "password1"

          fill_in "Address Label", with: "Main Location"
          fill_in "Address", with: "44 E. 8th St"
          fill_in "City", with: "Holland"
          select "Michigan", from: "State"
          fill_in "Postal Code", with: "49423"
          fill_in "Phone", with: "616-555-1963"

          check "registration_terms_of_service"

          click_button "Sign Up"
        end

        it 'creates a new organization' do
          expect(page).to have_content("You need to sign in or sign up before continuing.")

          expect(Organization.count).to eql(1)
          expect(Organization.last.name).to eql("Collective Idea")
          expect(Organization.last.active).to eql(true)
          expect(Organization.last.can_sell?).to eql(false)
        end

        it 'does not send a confirmation email' do
          expect(mailbox_for("daniel@collectiveidea.com")).to be_empty
        end

        # it 'sends the market managers a notification' do
        #   open_email(manager.email)
        #   expect(current_email.body).to have_content("A new organization has registered for your market!")
        # end
      end

      context "sad path" do
        it 'is shows error messages' do
          switch_to_subdomain market.subdomain
          visit root_path

          click_link "Request an Account"

          expect(page).to have_content("Registration: Step One")

          fill_in "Contact Name", with: "Daniel Morrison"
          fill_in "Contact Email", with: "daniel@collectiveidea.com"
          fill_in "Password", with: "password1"
          fill_in "Retype Password", with: "password1"

          fill_in "Address Label", with: "Main Location"
          fill_in "Address", with: "44 E. 8th St"
          fill_in "City", with: "Holland"
          select "Michigan", from: "State"
          fill_in "Postal Code", with: "49423"
          fill_in "Phone", with: "616-555-1963"

          click_button "Sign Up"

          expect(page).to have_content("Unable to complete registration")
          expect(page).to have_content("Registration: Step One")
          expect(page).to have_content("Name can't be blank")

          expect(Organization.count).to eql(0)
        end
      end
    end

    context "market managed activations" do
      let!(:market) { create(:market, managers: [manager], auto_activate_organizations: false) }

      context "happy path" do
        before do
          switch_to_subdomain market.subdomain
          visit root_path

          click_link "Request an Account"

          expect(page).to have_content("Registration: Step One")

          fill_in "Organization Name", with: "Collective Idea"
          fill_in "Contact Name", with: "Daniel Morrison"
          fill_in "Contact Email", with: "daniel@collectiveidea.com"
          fill_in "Password", with: "password1"
          fill_in "Retype Password", with: "password1"

          fill_in "Address Label", with: "Main Location"
          fill_in "Address", with: "44 E. 8th St"
          fill_in "City", with: "Holland"
          select "Michigan", from: "State"
          fill_in "Postal Code", with: "49423"
          fill_in "Phone", with: "616-555-1963"

          check "registration_terms_of_service"

          click_button "Sign Up"
        end

        it "creates a new organization" do
          expect(page).to have_content("Registration: Step Two")
          expect(page).to have_content("daniel@collectiveidea.com")

          expect(Organization.count).to eql(1)
          expect(Organization.last.name).to eql("Collective Idea")
        end

        it "sends a confirmation email" do
          open_email("daniel@collectiveidea.com")
          expect(current_email.body).to have_content("Verify Email Address")
          expect(current_email.body).to have_content(market.name)
        end

        it "creates a new organization" do
          expect(Organization.count).to eql(1)
          expect(Organization.last.name).to eql("Collective Idea")
          expect(Organization.last.active).to eql(false)
          expect(Organization.last.markets).to eq([market])
        end

        # it 'sends the market managers a notification' do
        #   open_email(manager.email)
        #   expect(current_email.body).to have_content("A new organization has registered for your market!")
        # end
      end

      context "sad path" do
        it 'is shows error messages' do
          switch_to_subdomain market.subdomain
          visit root_path

          click_link "Request an Account"

          expect(page).to have_content("Registration: Step One")

          fill_in "Contact Name", with: "Daniel Morrison"
          fill_in "Contact Email", with: "daniel@collectiveidea.com"
          fill_in "Password", with: "password1"
          fill_in "Retype Password", with: "password1"

          fill_in "Address Label", with: "Main Location"
          fill_in "Address", with: "44 E. 8th St"
          fill_in "City", with: "Holland"
          select "Michigan", from: "State"
          fill_in "Postal Code", with: "49423"
          fill_in "Phone", with: "616-555-1963"

          click_button "Sign Up"

          expect(page).to have_content("Unable to complete registration")
          expect(page).to have_content("Registration: Step One")
          expect(page).to have_content("Name can't be blank")

          expect(Organization.count).to eql(0)
        end
      end
    end
  end

end
