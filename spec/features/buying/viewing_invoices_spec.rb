require 'spec_helper'

describe "Buyer invoices" do

  let!(:market)    { create(:market) }

  let!(:sellers)   { create(:organization, :seller, markets: [market]) }
  let!(:apples)    { create(:product, :sellable, name: "Apples", organization: sellers) }
  let!(:oranges)   { create(:product, :sellable, name: "Oranges", organization: sellers) }
  let!(:grapes)    { create(:product, :sellable, name: "Grapes", organization: sellers) }

  let!(:buyers)    { create(:organization, :buyer, markets: [market]) }
  let!(:user)      { create(:user, organizations: [buyers]) }

  let!(:others)     { create(:organization, :buyer, markets: [market]) }
  let!(:other_user) { create(:user, organizations: [others]) }

  let!(:ordered_apples) { create(:order_item, product: apples) }
  let!(:ordered_grapes) { create(:order_item, product: grapes) }
  let!(:invoiced_order) { create(:order, market: market, organization: buyers, items: [ordered_apples, ordered_grapes], invoiced_at: 1.day.ago) }

  let!(:ordered_oranges)  { create(:order_item, product: oranges) }
  let!(:uninvoiced_order) { create(:order, market: market, organization: buyers, items: [ordered_oranges]) }

  let!(:ordered_oranges2) { create(:order_item, product: oranges) }
  let!(:others_order)     { create(:order, market: market, organization: others, items: [ordered_oranges2], invoiced_at: 2.days.ago) }


  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)

    visit dashboard_path
  end

  it "shows a list of the buyers invoices" do
    click_link "Financials"

    expect(page).to have_content("Financials Overview")

    click_link "Review Invoices"

    expect(page).to have_content("Invoices")

    invoices = Dom::Admin::Financials::InvoiceRow.all
    expect(invoices.map(&:order_number)).to eql([invoiced_order.order_number])
  end

end
