require "spec_helper"

feature "Downloading table tents or posters", js:true do
  let(:user) {create :user, :buyer}
  let(:organization) {user.organizations.first}
  let(:market_org) { create(:organization, :market)}
  let(:market) {user.markets.first}
  let(:order) {create :order, :with_items, organization: organization, market: market}

  before do
    market.organization = market_org
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
  end

  scenario "lets users download a Table Tent for a placed order", pdf: true do
    visit order_path(order)
    expect(page).to have_text "Download the table tents"
    find(".app-download-table-tents-btn").click
    expect(page).to have_text 'Table Tents (4" x 6")'
    expect(page).to have_text 'Why use table tents?'
    click_on "Download the PDF"
    #expect(page).to have_text "Generating"

    # EGAD
    patiently do
      uid = current_path[1..-1]
      order_printably = OrderPrintable.find_by(pdf_uid: uid)
      expect(order_printably).to be
      expect(order_printably.pdf).to be
      expect(order_printably.pdf.file).to be
      expect(order_printably.pdf.file.readlines.first).to match(/PDF-1\.4/)
    end
  end

  scenario "lets users download a Poster for a placed order", pdf: true do
    visit order_path(order)
    expect(page).to have_text "Download the posters"
    find(".app-download-posters-btn").click
    expect(page).to have_text 'Posters (8.5" x 11")'
    expect(page).to have_text 'Why use posters?'
    click_on "Download the PDF"
    #expect(page).to have_text "Generating"

    # EGAD.
    # We were having MAJRO TRUBL getting the PDF to actually fully render.  Dragonfly URL hell yall.
    patiently do
      uid = current_path[1..-1]
      order_printably = OrderPrintable.find_by(pdf_uid: uid)
      expect(order_printably).to be
      expect(order_printably.pdf).to be
      expect(order_printably.pdf.file).to be
      expect(order_printably.pdf.file.readlines.first).to match(/PDF-1\.4/)
    end
  end
end
