require 'spec_helper'

describe "Register" do
  context "a new organization for a market" do
    let!(:market) { create(:market) }

    context "automatically activated" do
      it 'is successful' do
        switch_to_subdomain market.subdomain
        visit root_path

        click_link "Register an account"

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

        click_button "Sign Up"

        expect(page).to have_content("Registration: Step Two")
        expect(page).to have_content("daniel@collectiveidea.com")

        expect(Organization.count).to eql(1)
        expect(Organization.last.name).to eql("Collective Idea")

        open_email("daniel@collectiveidea.com")
        expect(current_email.body).to have_content("Verify Email Address")
      end

      it 'is shows error messages' do
        switch_to_subdomain market.subdomain
        visit root_path

        click_link "Register an account"

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
