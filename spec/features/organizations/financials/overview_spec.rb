require 'spec_helper'

feature "Seller Financial Overview" do
  let!(:market)  { create(:market, po_payment_term: 30) }
  let!(:seller)  { create(:organization, markets: [market]) }
  let!(:seller2)  { create(:organization, markets: [market]) }

  let!(:user)    { create(:user, organizations: [seller]) }

  let!(:kale) { create(:product, :sellable, organization: seller, name: "Kale") }
  let!(:peas) { create(:product, :sellable, organization: seller, name: "Peas") }
  let!(:from_different_seller) { create(:product, :sellable, name: "Apples") }

  let!(:buyer1) { create(:organization) }
  let!(:buyer2) { create(:organization) }

  describe "Overdue" do
    context "no overdue payments for seller" do
      it "has a value of $0.00" do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        click_link "Financials"

        expect(financial_row("Overdue").amount).to eql("$0.00")
      end
    end

    context "overdue orders in the system" do
      before do
        # Overdue Order
        Timecop.travel 32.days.ago do
          create(:order, payment_method: "purchase order", items:[
            create(:order_item, quantity: 5, product: peas, delivery_status: "delivered"),
            create(:order_item, quantity: 7, product: kale, delivery_status: "delivered"),
            create(:order_item, quantity: 7, product: from_different_seller) # Not included in overdue total
          ])
        end

        # Order that's not overdue
        create(:order, payment_method: "purchase order", items:[
          create(:order_item, quantity: 1, product: peas, delivery_status: "delivered")
        ])
      end

      it "shows a sum of overdue payments for the seller" do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        click_link "Financials"

        expect(financial_row("Overdue").amount).to eql("$83.88")
      end
    end

    context "Market manager has not yet set PO terms for the market" do
      let!(:market) { create(:market) }
      it "displays as $0.00" do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        click_link "Financials"

        expect(financial_row("Overdue").amount).to eql("$0.00")
      end
    end
  end

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
