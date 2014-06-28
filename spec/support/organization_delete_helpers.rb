module OrganizationHelpers
  def delete_organization(org)
    visit admin_organizations_path

    expect(page).to have_content(org.name)
    org_row = Dom::Admin::OrganizationRow.find_by_name(org.name)

    within(org_row.node) do
      click_link "Delete"
    end
  end
end

RSpec.configure do |config|
  config.include OrganizationHelpers
end
