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

      it "does not update the product inventory" do
        expect {
          subject
        }.to_not change {
          product.lots.first.reload.quantity
        }.from(145)
      end
    end

    context "more then ordered" do
      subject {
        visit admin_order_path(order)

        item = Dom::Order::ItemRow.first
        expect(item.total).to have_content("$15.00")

        item.set_quantity_delivered(7)
        click_button "Update quantities"
      }

      it "updates the item total" do
        subject

        item = Dom::Order::ItemRow.first
        expect(item.total).to have_content("$21.00")
      end

      it "updates the grand total for the order" do
        subject

        expect(page).to have_content("Grand Total: $21.00")
      end

      it "does not update the product inventory" do
        expect {
          subject
        }.to_not change {
          product.lots.first.reload.quantity
        }.from(145)
      end
    end

    context "invalid input" do
      before do
        visit admin_order_path(order)

        item = Dom::Order::ItemRow.first
        expect(item.total).to have_content("$15.00")
      end

      it "shows an error for negative values" do
        item = Dom::Order::ItemRow.first
        item.set_quantity_delivered("-1")
        click_button "Update quantities"

        expect(page).to have_content("must be greater than or equal to 0")
      end

      it "shows an error for non-numerical values" do
        item = Dom::Order::ItemRow.first
        item.set_quantity_delivered("bad")
        click_button "Update quantities"

        expect(page).to have_content("is not a number")
      end

      it "shows an error for insanely large numbers" do
        item = Dom::Order::ItemRow.first
        item.set_quantity_delivered("2147483648")
        click_button "Update quantities"

        expect(page).to have_content("must be less than 2147483647")
      end
    end
  end
end
