require 'spec_helper'

describe "Edit quantity ordered" do
  let!(:market)          { create(:market, :with_addresses, market_seller_fee: 5, local_orbit_seller_fee: 4) }
  let!(:monday_delivery) { create(:delivery_schedule, day: 1)}
  let!(:seller)          { create(:organization, :seller, markets: [market]) }
  let!(:product_lot)     { create(:lot, quantity: 145) }
  let!(:product)         { create(:product, :sellable, organization: seller, lots: [product_lot])}

  let!(:product2)         { create(:product, :sellable, organization: seller)}

  let!(:buyer)          { create(:organization, :buyer, markets: [market]) }

  let!(:delivery)       { monday_delivery.next_delivery }
  let!(:order_item)     { create(:order_item, product: product, quantity: 5, unit_price: 3.00) }
  let!(:order_item_lot) { create(:order_item_lot, quantity: 5, lot: product_lot, order_item: order_item) }
  let!(:order)          { create(:order, market: market, organization: buyer, delivery: delivery, items:[order_item], payment_method: 'ach')}
  let!(:bank_account)   { create(:bank_account, :checking, :verified, bankable: buyer) }
  let!(:payment)        { create(:payment, :checking, bank_account: bank_account, orders: [order], amount: 15.00) }

  context "as a buyer" do
    let!(:user) { create(:user, organizations: [buyer]) }

    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
      visit admin_order_path(order)
    end

    it "gives a 404" do
      expect(page.status_code).to eql(404)
    end
  end

  context "as a seller" do
    let!(:user) { create(:user, organizations: [seller]) }

    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
      visit admin_order_path(order)
    end

    it "should not show quantity ordered fields" do
      expect(page).to_not have_css(".quantity-ordered")
    end

    it "should not have an update button" do
      expect(page).to_not have_button("Update quantities")
    end
  end

  context "as a market manager" do
    let!(:user) { create(:user, managed_markets: [market]) }

    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
    end

    it "should not be able to change the quantity ordered of a delivered item" do
      order_item.update(delivery_status: 'delivered')
      visit admin_order_path(order)

      expect(page).to_not have_css(".quantity-ordered")
    end

    # Fixes: https://www.pivotaltracker.com/story/show/73913054
    context "hitting enter on a quantity field", js:true do
      it "does not submit the form" do
        visit admin_order_path(order)

        item = Dom::Order::ItemRow.first
        expect(item.total).to have_content("$15.00")
        expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$15.00")

        item.set_quantity_ordered(2)

        expect(UpdateBalancedPurchase).not_to receive(:perform)
        item.quantity_delivered_field.native.send_keys(:return)
        expect(item.quantity_delivered_field.value).to eq("2")

        item2 = Dom::Order::ItemRow.all.last
        expect(item2.quantity_delivered_field.value).not_to eq("1")
      end
    end

    context "less then ordered" do
      before do
        expect(UpdateBalancedPurchase).to receive(:perform).and_return(double("interactor", "success?" => true))
      end

      subject {
        visit admin_order_path(order)

        item = Dom::Order::ItemRow.first
        expect(item.total).to have_content("$15.00")
        expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$15.00")

        item.set_quantity_ordered(2)
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

      it "updates the fees for the order" do
        subject

        expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$6.00")
        expect(Dom::Admin::OrderSummaryRow.first.market_fees).to eql("$0.30")
        expect(Dom::Admin::OrderSummaryRow.first.net_sale).to eql("$5.38")
      end

      it "updates the product inventory" do
        expect {
          subject
        }.to change {
          product.lots.first.reload.quantity
        }.from(140).to(143)
      end

      it "does not change the delivery status" do
        expect { subject }.to_not change{ order_item.reload.delivery_status }.from("pending")
      end
    end

    context "more then ordered" do
      before do
        expect(UpdateBalancedPurchase).to receive(:perform).and_return(double("interactor", "success?" => true))
      end

      subject {
        visit admin_order_path(order)

        item = Dom::Order::ItemRow.first
        expect(item.total).to have_content("$15.00")
        expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$15.00")
        expect(Dom::Admin::OrderSummaryRow.first.net_sale).to eql("$15.00")

        item.set_quantity_ordered(7)
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

      it "updates the fees for the order" do
        subject

        expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$21.00")
        expect(Dom::Admin::OrderSummaryRow.first.market_fees).to eql("$1.05")
        expect(Dom::Admin::OrderSummaryRow.first.net_sale).to eql("$18.84")
      end

      it "updates the product inventory" do
        expect {
          subject
        }.to change {
          product.lots.first.reload.quantity
        }.from(140).to(138)
      end

      it "does not change the delivery status" do
        expect { subject }.to_not change{ order_item.reload.delivery_status }.from("pending")
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
        item.set_quantity_ordered("-1")
        click_button "Update quantities"

        expect(page).to have_content("must be greater than or equal to 0")
        expect(Dom::Order::ItemRow.first.delivery_status).to eql("Pending")
      end

      it "shows an error for non-numerical values" do
        item = Dom::Order::ItemRow.first
        item.set_quantity_ordered("bad")
        click_button "Update quantities"

        expect(page).to have_content("is not a number")
        expect(Dom::Order::ItemRow.first.delivery_status).to eql("Pending")
      end

      it "shows an error for insanely large numbers" do
        item = Dom::Order::ItemRow.first
        item.set_quantity_ordered("2147483648")
        click_button "Update quantities"

        expect(page).to have_content("must be less than 2147483647")
        expect(Dom::Order::ItemRow.first.delivery_status).to eql("Pending")
      end
    end
  end

  context "as an admin" do
    let!(:user) { create(:user, :admin) }

    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
    end

    it "should not be able to change the quantity ordered of a delivered item" do
      order_item.update(delivery_status: 'delivered')
      visit admin_order_path(order)

      expect(page).to_not have_css(".quantity-ordered")
    end

    context "less then ordered" do
      before do
        expect(UpdateBalancedPurchase).to receive(:perform).and_return(double("interactor", "success?" => true))
      end

      subject {
        visit admin_order_path(order)

        item = Dom::Order::ItemRow.first
        expect(item.total).to have_content("$15.00")
        expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$15.00")

        item.set_quantity_ordered(2)
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

      it "updates the fees for the order" do
        subject

        expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$6.00")
        expect(Dom::Admin::OrderSummaryRow.first.market_fees).to eql("$0.30")
        expect(Dom::Admin::OrderSummaryRow.first.net_sale).to eql("$5.38")
      end

      it "updates the product inventory" do
        expect {
          subject
        }.to change {
          product.lots.first.reload.quantity
        }.from(140).to(143)
      end

      it "does not change the delivery status" do
        expect { subject }.to_not change{ order_item.reload.delivery_status }.from("pending")
      end
    end

    context "more then ordered" do
      before do
        expect(UpdateBalancedPurchase).to receive(:perform).and_return(double("interactor", "success?" => true))
      end

      subject {
        visit admin_order_path(order)

        item = Dom::Order::ItemRow.first
        expect(item.total).to have_content("$15.00")
        expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$15.00")
        expect(Dom::Admin::OrderSummaryRow.first.net_sale).to eql("$15.00")

        item.set_quantity_ordered(7)
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

      it "updates the fees for the order" do
        subject

        expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$21.00")
        expect(Dom::Admin::OrderSummaryRow.first.market_fees).to eql("$1.05")
        expect(Dom::Admin::OrderSummaryRow.first.net_sale).to eql("$18.84")
      end

      it "updates the product inventory" do
        expect {
          subject
        }.to change {
          product.lots.first.reload.quantity
        }.from(140).to(138)
      end

      it "does not change the delivery status" do
        expect { subject }.to_not change{ order_item.reload.delivery_status }.from("pending")
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
        item.set_quantity_ordered("-1")
        click_button "Update quantities"

        expect(page).to have_content("must be greater than or equal to 0")
        expect(page).to_not have_content("failed to update your payment")
        expect(Dom::Order::ItemRow.first.delivery_status).to eql("Pending")
      end

      it "shows an error for non-numerical values" do
        item = Dom::Order::ItemRow.first
        item.set_quantity_ordered("bad")
        click_button "Update quantities"

        expect(page).to have_content("is not a number")
        expect(page).to_not have_content("failed to update your payment")
        expect(Dom::Order::ItemRow.first.delivery_status).to eql("Pending")
      end

      it "shows an error for insanely large numbers" do
        item = Dom::Order::ItemRow.first
        item.set_quantity_ordered("2147483648")
        click_button "Update quantities"

        expect(page).to have_content("must be less than 2147483647")
        expect(page).to_not have_content("failed to update your payment")
        expect(Dom::Order::ItemRow.first.delivery_status).to eql("Pending")
      end
    end

    context "payment processor error" do
      let!(:payment) { create(:payment, :checking, bank_account: bank_account, balanced_uri: '/debit-1', orders: [order], amount: 15.00) }

      before do
        expect(Balanced::Transaction).to receive(:find).with('/debit-1').and_raise(StandardError)

        visit admin_order_path(order)

        item = Dom::Order::ItemRow.first
        expect(item.total).to have_content("$15.00")
      end

      it "shows an error" do
        item = Dom::Order::ItemRow.first
        item.set_quantity_ordered("2")
        click_button "Update quantities"

        expect(page).to have_content("failed to update your payment")
        item = Dom::Order::ItemRow.first
        expect(item.total).to have_content("$15.00")
      end
    end
  end
end
