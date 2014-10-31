require "spec_helper"

feature "Downloading table tents or posters" do
  let(:user) {create :user, :buyer}
  let(:organization) {user.organizations.first}
  let(:market) {user.markets.first}
  let(:order) {create :order, :with_items, organization: organization}

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
  end

  scenario "lets users download a Table Tent for a placed order" do
    visit order_path(order)
    expect(page).to have_text "Download the table tents"
    find(".app-download-table-tents-btn").click
    expect(page).to have_text 'Table Tents (4" x 6")'
    expect(page).to have_text 'Why use table tents?'
    click_on "Download the PDF"
    expect(page.body).to match(/^%PDF-1.4/)
  end

  scenario "lets users download a Poster for a placed order" do
    visit order_path(order)
    expect(page).to have_text "Download the posters"
    find(".app-download-posters-btn").click
    expect(page).to have_text 'Posters (8.5" x 11")'
    expect(page).to have_text 'Why use posters?'
    click_on "Download the PDF"
    expect(page.body).to match(/^%PDF-1.4/)
  end
end
