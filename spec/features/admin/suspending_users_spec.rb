require "spec_helper"

feature "Suspend/enable a user" do
  let!(:target_user) { create(:user, organizations: [org1, org2]) }

  let!(:market1) { create(:market) }
  let!(:market2) { create(:market) }
  let!(:org1) { create(:organization, markets: [market1, market2]) }
  let!(:org2) { create(:organization, markets: [market1]) }

  before do
    switch_to_subdomain(market1.subdomain)
  end

  def globally_suspend_user(opts={})
    logged_in_user = opts[:as]

    sign_in_as(logged_in_user)
    visit admin_users_path

    user_row = Dom::Admin::UserRow.find_by_email(target_user.email)

    expect {
      within(user_row.node) do
        click_link "Suspend"
      end
    }.to change {
      target_user.reload
      target_user.organizations.count
    }.from(2).to(0)


    user_row = Dom::Admin::UserRow.find_by_email(target_user.email)
    expect(user_row).to have_content("Enable")
  end

  def globally_enable_user(opts={})
    suspend_user(user: target_user, org: org1)
    suspend_user(user: target_user, org: org2)

    logged_in_user = opts[:as]

    sign_in_as(logged_in_user)
    visit admin_users_path

    user_row = Dom::Admin::UserRow.find_by_email(target_user.email)

    expect {
      within(user_row.node) do
        click_link "Enable"
      end
    }.to change {
      target_user.reload
      target_user.organizations.count
    }.from(0).to(2)

    user_row = Dom::Admin::UserRow.find_by_email(target_user.email)
    expect(user_row).to have_content("Suspend")

  end

  context "as an admin" do
    let!(:admin) { create(:user, role: "admin") }

    scenario "Suspending a user" do
      globally_suspend_user(as: admin)
    end

    scenario "Enabling a user" do
      globally_enable_user(as: admin)
    end
  end

  context "as a market manager" do
    # NOTE: Currently, we're allowing Market managers to suspend a user throughout the
    let!(:market_manager) { create(:user, managed_markets: [market1]) }

    scenario "Suspending a user" do
      globally_suspend_user(as: market_manager)
    end

    scenario "Enabling a user" do
      globally_enable_user(as: market_manager)
    end
  end
end
