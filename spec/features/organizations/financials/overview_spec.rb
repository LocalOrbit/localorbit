require 'spec_helper'

feature "Seller Financial Overview" do
  let!(:market)  { create(:market) }
  let!(:seller)  { create(:organization, markets: [market]) }
  let!(:user)    { create(:user, organizations: [seller]) }
  let!(:kale) { create(:product, :sellable, name: "Kale") }
  let!(:peas) { create(:product, :sellable, name: "Peas") }

  let!(:buyer1) { create(:organization) }
  let!(:buyer2) { create(:organization) }

  # Order that pays out today
  # Buyer paid 7 days ago
  # Delivered up to 9 days ago
  let(:order_today) { crate(:order) }
  let(:order_item1) { create(:order_item, product: peas, order: order_today) }
  let(:order_item2) { create(:order_item, product: peas, order: order_today) }

  scenario "Seller navigates to their financial overview" do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
    click_link "Financials"

    expect(page).to have_content("Money In")
    expect(page).to have_content("This is a snapshot")
  end

  def visit_financials
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
    visit "/admin/financials"
  end

  def financial_row(title)
    Dom::Admin::Financials::OverviewStat.find_by_title(title)
  end

  scenario "Seller navigates directly to their financial overview" do
    visit_financials
    expect(page).to have_content("Money In")
    expect(page).to have_content("This is a snapshot")
  end

  scenario "Seller checks their financial overview with no orders" do
    visit_financials

    expect(financial_row("Overdue").amount).to eql("$0.00")
    expect(financial_row("Today").amount).to eql("$0.00")
    expect(financial_row("Next 7 Days").amount).to eql("$0.00")
    expect(financial_row("Next 30 Days").amount).to eql("$0.00")
  end

  scenario "Seller checks their financial overview with several orders" do
    items = create_list(:order_items)
    order = create(:order, :with_items, market: market, organization: seller, delivery_fees: 10.00, total_cost: 19.00)

    visit_financials
    expect(financial_row("Overdue").amount).to eql("$0.00")
    expect(financial_row("Today").amount).to eql("$0.00")
    expect(financial_row("Next 7 Days").amount).to eql("$0.00")
  end
end
