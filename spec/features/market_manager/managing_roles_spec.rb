require "spec_helper"

describe "Managing roles" do
  let!(:market)  { create(:market) }

  let!(:role) { create(:role, name: "Test Role", activities:["dashboard:index"], organization_id: market.id) }

  context "as a market manager", :js do
    let(:user) { create(:user, :market_manager, managed_markets: [market]) }

    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as user

      visit admin_roles_path
    end

    context "list view" do
      it "shows a list of the roles for the market" do
        expect(page).to have_content("Roles")

        roles = Dom::Admin::RoleRow.all
        skip 'Fails intermittently, revisit w/ rails 5 transactional rollbacks in specs'
        expect(roles.count).to eql(1)
      end
    end

    context "single market membership" do
      context "create a role", :js do
        it "accepts valid input" do
          click_link "Add Role"

          fill_in "Name", with: "User"
          check 'dashboard-perm'
          check 'delivery-perm'

          click_button "Add Role"

          expect(page).to have_content("Successfully added role")

          roles = Dom::Admin::RoleRow.all
          expect(roles.count).to eql(2)
        end

        it "displays errors for invalid input" do
          click_link "Add Role"

          fill_in "Name", with: ""

          click_button "Add Role"

          expect(page).to_not have_content("Successfully added role")
          expect(page).to have_content("No Permissions Selected")
        end
      end

      it "accepts valid input" do
        click_link role.name

        fill_in "Name", with: "Changed Role"

        click_button "Save Role"

        expect(page).to have_content("Successfully updated role")

        roles = Dom::Admin::RoleRow.all
        expect(roles.count).to eql(1)
        expect(roles.map(&:name)).to include("Changed Role")
      end

      it "displays errors for invalid input" do
        click_link role.name

        fill_in "Name", with: ""

        click_button "Save Role"

        expect(page).to_not have_content("Successfully updated role")
        expect(page).to have_content("Unable to update role")
      end

    end
  end
end
