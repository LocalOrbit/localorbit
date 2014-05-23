require 'spec_helper'

describe 'Editing an order' do
  let!(:market)          { create(:market, :with_addresses) }
  let!(:monday_delivery) { create(:delivery_schedule, day: 1)}
  let!(:seller)          { create(:organization, :seller, markets: [market]) }
  let!(:product)         { create(:product, :sellable, organization: seller)}

  let!(:buyer)      { create(:organization, :buyer, markets: [market]) }

  let!(:delivery)   { monday_delivery.next_delivery }
  let!(:order_item) { create(:order_item, product: product, quantity: 5, unit_price: 3.00) }
  let!(:order)      { create(:order, market: market, organization: buyer, delivery: delivery, items:[order_item])}

  let!(:user)       { create(:user, organizations: [seller]) }


  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
  end

  context "quantity delivered" do
    context "less then ordered" do
      subject {
        visit admin_order_path(order)

        item = Dom::Order::ItemRow.first
        expect(item.total).to have_content("$15.00")

        item.set_quantity_delivered(2)
        click_button "Update quantities"
      }

      it "updates the item total" do
        subject

        item = Dom::Order::ItemRow.first
        expect(item.total).to have_content("$6.00")
      end

      it "updates the grand total for the order" do
        subject

        expect(page).to have_content("Grand Total: $6.00")
      end

      it "updates the product inventory" do
        expect {
          subject
        }.to change {
          product.lots.first.reload.quantity
        }.from(145).to(148)
      end
    end
  end
end
