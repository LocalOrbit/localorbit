require "spec_helper"

feature "viewing and managing users" do
  let!(:admin)          { create(:user, :admin) }
  let!(:market)         { create(:market, name: "Test Market") }
  let!(:market2)        { create(:market) }
  let!(:market_manager) { create(:user, :market_manager, managed_markets: [market]) }

  let!(:organization)   { create(:organization, name: "Test Org 1", markets: [market]) }
  let!(:organization2)  { create(:organization, name: "Test Org 2", markets: [market]) }
  let!(:orphan_org)     { create(:organization, markets: []) }
  let!(:user)           { create(:user, name: "New Dude", organizations: [organization, organization2, orphan_org]) }
  let!(:user2)          { create(:user) }

  context "as an admin" do
    before do
      switch_to_main_domain
      sign_in_as(admin)
    end

    scenario "getting there" do
      click_link "Market Admin"
      click_link "All Users"
      within "h1" do
        expect(page).to have_content("Users")
      end
    end

    scenario "viewing all users" do
      visit "/admin/users"
      within "h1" do
        expect(page).to have_content("Users")
      end
      expect(page).to have_content(market_manager.name)
      expect(page).to have_content(market_manager.email)
      expect(page).to have_content(admin.name)
      expect(page).to have_content(admin.email)
      expect(page).to have_content(market.name)
    end

    scenario "viewing user without name" do
      visit "/admin/users"
      user_row = Dom::Admin::UserRow.find_by_email(user2.email)

      expect(user_row.name).to eq("Edit")
    end

    context "managing a user" do
      before do
        visit edit_admin_user_path(user)
        expect(page).to have_content("Editing User: New Dude")
      end

      scenario "change password" do
        fill_in "New Password", with: "password2"
        fill_in "Confirm Password", with: "password2"

        expect(UserMailer).to receive(:user_updated).with(user, admin, user.email).and_return(double(:user_mailer, deliver: true))

        click_button "Save Changes"

        user_row = Dom::Admin::UserRow.find_by_email(user.email)

        expect(user.reload.valid_password?("password2")).to be true
      end

      scenario "change email address" do
        fill_in "Email", with: "wrong@example.com"

        expect(UserMailer).to receive(:user_updated).with(user, admin, user.email).and_return(double(:user_mailer, deliver: true))

        click_button "Save Changes"

        user_row = Dom::Admin::UserRow.find_by_email("wrong@example.com")

        expect(user_row.email).to eq("wrong@example.com")
      end

      scenario "change name" do
        fill_in "Name", with: "Wrong Dude"

        expect(UserMailer).to receive(:user_updated).with(user, admin, user.email).and_return(double(:user_mailer, deliver: true))

        click_button "Save Changes"

        user_row = Dom::Admin::UserRow.find_by_email(user.email)

        expect(user_row.name).to eq("Wrong Dude")
      end

      it "does not show deleted organizations" do
        expect(page).to_not have_content(orphan_org.name)
      end
    end
  end

  context "as a market manager" do
    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(market_manager)
    end

    scenario "viewing only relevant users" do
      visit admin_users_path
      within "h1" do
        expect(page).to have_content("Users")
      end

      manager_row = Dom::Admin::UserRow.find_by_email(market_manager.email)
      user_row = Dom::Admin::UserRow.find_by_email(user.email)

      expect(manager_row.affiliations).to eql("Test Market, Market Manager")
      expect(user_row.affiliations).to eql("Test Market: Test Org 1, Supplier Test Market: Test Org 2, Supplier")
    end

    context "managing a user" do
      before do
        visit edit_admin_user_path(user)
        expect(page).to have_content("Editing User: New Dude")
      end

      scenario "change password" do
        fill_in "New Password", with: "password2"
        fill_in "Confirm Password", with: "password2"

        expect(UserMailer).to receive(:user_updated).with(user, market_manager, user.email).and_return(double(:user_mailer, deliver: true))

        click_button "Save Changes"

        user_row = Dom::Admin::UserRow.find_by_email(user.email)

        expect(user.reload.valid_password?("password2")).to be true
      end

      scenario "change email address" do
        fill_in "Email", with: "wrong@example.com"

        expect(UserMailer).to receive(:user_updated).with(user, market_manager, user.email).and_return(double(:user_mailer, deliver: true))

        click_button "Save Changes"

        user_row = Dom::Admin::UserRow.find_by_email("wrong@example.com")

        expect(user_row.email).to eq("wrong@example.com")
      end

      scenario "change name" do
        fill_in "Name", with: "Wrong Dude"

        expect(UserMailer).to receive(:user_updated).with(user, market_manager, user.email).and_return(double(:user_mailer, deliver: true))

        click_button "Save Changes"

        user_row = Dom::Admin::UserRow.find_by_email(user.email)

        expect(user_row.name).to eq("Wrong Dude")
      end
    end

    scenario "trying to edit a non-accessible user" do
      inaccessible_user = create(:user)

      visit edit_admin_user_path(inaccessible_user)

      expect(page.body).to have_content("The page you were looking for is not available at this address.")
    end

    scenario "viewing only relevant users after deleting an organization" do
      delete_organization(organization)
      visit admin_users_path

      within "h1" do
        expect(page).to have_content("Users")
      end

      manager_row = Dom::Admin::UserRow.find_by_email(market_manager.email)
      user_row = Dom::Admin::UserRow.find_by_email(user.email)

      expect(manager_row.affiliations).to eql("Test Market, Market Manager")
      expect(user_row.affiliations).to eql("Test Market: Test Org 2, Supplier")
    end

    scenario "Suspending a user from an organization", :suspend_user do
      visit admin_organization_users_path(organization2)

      expect(page).to have_content("Suspend")
      expect(page).to_not have_content("Enable")

      click_link "Suspend"
      expect(page).to have_content("Enable")
      expect(page).to_not have_content("Suspend")
    end
  end
end
