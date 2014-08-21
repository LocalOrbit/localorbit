require "spec_helper"

describe "Impersonating a user" do
  let!(:market1)        { create(:market) }
  let!(:buyer1)         { create(:organization, :buyer, markets: [market1]) }
  let!(:buyer1_user)    { create(:user, organizations: [buyer1]) }

  let!(:market2)        { create(:market) }
  let!(:buyer2)         { create(:organization, :buyer, markets: [market2]) }
  let!(:buyer2_user)    { create(:user, organizations: [buyer2]) }
  let!(:market_manager) { create(:user, managed_markets: [market2]) }

  let(:user)     { create(:user)}

  before do
    switch_to_subdomain(market1.subdomain)
    sign_in_as(user)
  end

  context "as a seller" do
    it "does not show the 'login as' button" do
      visit admin_users_path

      expect(page).to_not have_content("Login As")
    end
  end

  context "as a market manager" do
    let!(:user)  { create(:user, managed_markets: [market1])}

    before do
      visit admin_users_path
    end

    it "does not show the 'login as' button" do
      expect(page).to have_content("Log In")
    end

    it "impersonates a user and exits that impersonation" do
      Dom::Admin::UserRow.find_by_email(buyer1_user.email).impersonate

      expect(page).to have_content("Impersonating #{buyer1_user.name}")
      expect(page).to_not have_content("Welcome #{user.name}")

      find("#exit-masquerade").click

      expect(page).to have_content("Welcome #{user.name}")
      expect(page).to_not have_content("Impersonating #{buyer1_user.name}")
    end
  end

  context "as an admin" do
    let!(:user)  { create(:user, role: "admin")}

    before do
      visit admin_users_path
    end

    it "does not show the 'login as' button" do
      expect(page).to have_content("Log In")
    end

    it "impersonates a user and exits that impersonation" do
      Dom::Admin::UserRow.find_by_email(buyer2_user.email).impersonate

      expect(page).to have_content("Impersonating #{buyer2_user.name}")
      expect(page).to_not have_content("Welcome #{user.name}")

      find("#exit-masquerade").click

      expect(page).to have_content("Welcome #{user.name}")
      expect(page).to_not have_content("Impersonating #{buyer2_user.name}")
    end

    it "does not allow impersonating a second person" do
      Dom::Admin::UserRow.find_by_email(market_manager.email).impersonate

      expect(page).to have_content("Impersonating #{market_manager.name}")
      expect(page).to_not have_content("Welcome #{user.name}")

      expect(current_host).to have_content(market2.subdomain)
      visit admin_users_path

      expect(page).to_not have_content("Login As")
    end
  end
end
