shared_examples "activates and deactivates organizations" do
  let!(:market)          { create(:market) }
  let!(:inactive_seller) { create(:organization, :seller, active: false, name: "Holland Farms", markets: [market]) }
  let!(:active_seller)   { create(:organization, :seller, active: true, name: "Franklin Farms", markets: [market]) }

  before do
    sign_out
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
    visit admin_organizations_path
  end

  it "changes the active status" do
    org_row = Dom::Admin::OrganizationRow.find_by_name(inactive_seller.name)
    org_row.activate!

    expect(page).to have_content("Updated #{inactive_seller.name}")
    org_row = Dom::Admin::OrganizationRow.find_by_name(inactive_seller.name)
    expect(org_row.node).not_to have_content("Activate")

    org_row = Dom::Admin::OrganizationRow.find_by_name(active_seller.name)
    org_row.deactivate!

    expect(page).to have_content("Updated #{active_seller.name}")
    org_row = Dom::Admin::OrganizationRow.find_by_name(active_seller.name)
    expect(org_row.node).not_to have_content("Deactivate")
  end
end
