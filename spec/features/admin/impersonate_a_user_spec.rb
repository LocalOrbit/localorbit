require "spec_helper"

describe "Impersonating a user" do
  let!(:market) { create(:market) }
  let(:user)  { create(:user)}

  let!(:buyer)      { create(:organization, :buyer, markets: [market]) }
  let!(:buyer_user) { create(:user, organizations: [buyer]) }

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
  end

  context "as a seller" do
    it "does not show the 'login as' button" do
      visit admin_users_path

      expect(page).to_not have_content("Login As")
    end
  end

  context "as an admin" do
    let!(:user)  { create(:user, role: "admin")}

    before do
      visit admin_users_path
    end

    it "does not show the 'login as' button" do
      expect(page).to have_content("Login As")
    end

    it "impersonates a user and exits that impersonation" do
      Dom::Admin::UserRow.find_by_email(buyer_user.email).impersonate

      expect(page).to have_content("Impersonating #{buyer_user.name}")
      expect(page).to_not have_content("Welcome #{user.name}")


      find("#exit-masquerade").click


      expect(page).to have_content("Welcome #{user.name}")
      expect(page).to_not have_content("Impersonating #{buyer_user.name}")
    end
  end
end
