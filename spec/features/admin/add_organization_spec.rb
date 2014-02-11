require "spec_helper"

describe "Admin adds an organization" do
  it "basic organization" do
    admin = create(:user, :admin)
    sign_in_as(admin)

    create(:market, name: "Market 1")
    create(:market, name: "Market 2")

    click_link "Organizations"
    click_link "Add Organization"

    within("#organization-info") do
      select "Market 2", from: "Market"
      fill_in "Name", with: "University of Michigan Farmers"
      fill_in "Who",  with: "Who Story"
      fill_in "How",  with: "How Story"
    end

    within("#organization-locations") do
      fill_in "Name",     with: "University of Michigan"
      fill_in "Address",  with: "500 S. State Street"
      fill_in "City",     with: "Ann Arbor"
      select  "Michigan", from: "State"
      fill_in "Zip",      with: "34599"
    end

    click_button "Add Organization"

    expect(page).to have_content("University of Michigan Farmers has been created")
  end
end
