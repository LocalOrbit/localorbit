require "spec_helper"

feature "Suspend/enable a user", :suspend_user do
  let!(:target_user) { create(:user, organizations: [org1, org2]) }

  let!(:market1) { create(:market) }
  let!(:market2) { create(:market) }

  let!(:org1) { create(:organization, markets: [market1, market2]) }
  let!(:org2) { create(:organization, markets: [market1]) }

  before do
    switch_to_subdomain(market1.subdomain)
  end

  def globally_suspend_user(opts={})
    sign_in_as(opts[:as])
    visit admin_users_path

    user_row = Dom::Admin::UserRow.find_by_email(target_user.email)

    expect {
      within(user_row.node) do
        click_link "Suspend"
      end
      expect(page).to have_content("Updated #{target_user.decorate.display_name}")
    }.to change {
      User.find(target_user.id).organizations.count
    }.from(2).to(0)

    user_row = Dom::Admin::UserRow.find_by_email(target_user.email)
    expect(user_row).to have_content("Enable")

    # See that the suspended pill is next to the organization
    user_row.node.all(".affiliations li").each do |a|
      expect(a).to have_content("Suspended")
    end
  end

  def globally_enable_user(opts={})
    suspend_user(user: target_user, org: org1)
    suspend_user(user: target_user, org: org2)

    sign_in_as(opts[:as])

    visit admin_users_path

    user_row = Dom::Admin::UserRow.find_by_email(target_user.email)

    expect {
      within(user_row.node) do
        click_link "Enable"
      end
      expect(page).to have_content("Updated #{target_user.decorate.display_name}")
    }.to change {

      User.find(target_user.id).organizations.count
    }.from(0).to(2)

    user_row = Dom::Admin::UserRow.find_by_email(target_user.email)
    expect(user_row).to have_content("Suspend")

    user_row.node.all(".affiliations li").each do |a|
      expect(a).to_not have_content("suspended")
    end
  end

  context "as an admin" do
    let!(:admin) { create(:user, :admin) }

    scenario "Suspending a user" do
      globally_suspend_user(as: admin)
    end

    scenario "Enabling a user" do
      globally_enable_user(as: admin)
    end

    scenario "Users in the system who have no organizations (pure market managers and admins)" do
      other_admin = create(:user, :admin)
      sign_in_as(admin)

      visit admin_users_path
      user_row = Dom::Admin::UserRow.find_by_email(other_admin.email)

      within(user_row.node) do
        expect(page).to_not have_content("Suspend")
        expect(page).to_not have_content("Enable")
      end
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
