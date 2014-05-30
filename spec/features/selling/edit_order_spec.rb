require 'spec_helper'

describe 'Editing an order' do
  let!(:market)          { create(:market, :with_addresses, market_seller_fee: 5, local_orbit_seller_fee: 4) }
  let!(:monday_delivery) { create(:delivery_schedule, day: 1)}
  let!(:seller)          { create(:organization, :seller, markets: [market]) }
  let!(:product)         { create(:product, :sellable, organization: seller)}

  let!(:buyer)      { create(:organization, :buyer, markets: [market]) }

  let!(:delivery)   { monday_delivery.next_delivery }
  let!(:order_item) { create(:order_item, product: product, quantity: 5, unit_price: 3.00) }
  let!(:order)      { create(:order, market: market, organization: buyer, delivery: delivery, items:[order_item], payment_method: 'ach')}
  let!(:payment)    { create(:payment, :checking, orders: [order], amount: 15.00) }

  context "quantity delivered" do
    context "as a buyer" do
      let!(:user) { create(:user, organizations: [buyer]) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_order_path(order)
      end

      it "should not show quantity delivered fields" do
        expect(page).to_not have_css(".quantity > input")
      end

      it "should not have an update button" do
        expect(page).to_not have_button("Update quantities")
      end
    end

    context "as a seller" do
      let!(:user) { create(:user, organizations: [seller]) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_order_path(order)
      end

      it "should not show quantity delivered fields" do
        expect(page).to_not have_css(".quantity > input")
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

      context "less then ordered" do
        before do
          expect(UpdateBalancedPurchase).to receive(:perform).and_return(double("interactor", "success?" => true))
        end

        subject {
          visit admin_order_path(order)

          item = Dom::Order::ItemRow.first
          expect(item.total).to have_content("$15.00")
          expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$15.00")

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

        it "updates the fees for the order" do
          subject

          expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$6.00")
          expect(Dom::Admin::OrderSummaryRow.first.market_fees).to eql("$0.30")
          expect(Dom::Admin::OrderSummaryRow.first.net_sale).to eql("$5.38")
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
        before do
          expect(UpdateBalancedPurchase).to receive(:perform).and_return(double("interactor", "success?" => true))
        end

        subject {
          visit admin_order_path(order)

          item = Dom::Order::ItemRow.first
          expect(item.total).to have_content("$15.00")
          expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$15.00")
          expect(Dom::Admin::OrderSummaryRow.first.net_sale).to eql("$15.00")

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

        it "updates the fees for the order" do
          subject

          expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$21.00")
          expect(Dom::Admin::OrderSummaryRow.first.market_fees).to eql("$1.05")
          expect(Dom::Admin::OrderSummaryRow.first.net_sale).to eql("$18.84")
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

    context "as an admin" do
      let!(:user) { create(:user, :admin) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
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

        it "updates the fees for the order" do
          subject

          expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$6.00")
          expect(Dom::Admin::OrderSummaryRow.first.market_fees).to eql("$0.30")
          expect(Dom::Admin::OrderSummaryRow.first.net_sale).to eql("$5.38")
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
        before do
          expect(UpdateBalancedPurchase).to receive(:perform).and_return(double("interactor", "success?" => true))
        end

        subject {
          visit admin_order_path(order)

          item = Dom::Order::ItemRow.first
          expect(item.total).to have_content("$15.00")
          expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$15.00")
          expect(Dom::Admin::OrderSummaryRow.first.net_sale).to eql("$15.00")

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

        it "updates the fees for the order" do
          subject

          expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$21.00")
          expect(Dom::Admin::OrderSummaryRow.first.market_fees).to eql("$1.05")
          expect(Dom::Admin::OrderSummaryRow.first.net_sale).to eql("$18.84")
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
          expect(page).to_not have_content("failed to update your payment")
        end

        it "shows an error for non-numerical values" do
          item = Dom::Order::ItemRow.first
          item.set_quantity_delivered("bad")
          click_button "Update quantities"

          expect(page).to have_content("is not a number")
          expect(page).to_not have_content("failed to update your payment")
        end

        it "shows an error for insanely large numbers" do
          item = Dom::Order::ItemRow.first
          item.set_quantity_delivered("2147483648")
          click_button "Update quantities"

          expect(page).to have_content("must be less than 2147483647")
          expect(page).to_not have_content("failed to update your payment")
        end
      end

      context "payment processor error" do
        let!(:payment) { create(:payment, :checking, orders: [order], amount: 15.00) }

        before do
          expect(Balanced::Debit).to receive(:find).and_throw(Exception)

          visit admin_order_path(order)

          item = Dom::Order::ItemRow.first
          expect(item.total).to have_content("$15.00")
        end

        it "shows an error" do
          item = Dom::Order::ItemRow.first
          item.set_quantity_delivered("2")
          click_button "Update quantities"

          expect(page).to have_content("failed to update your payment")
          item = Dom::Order::ItemRow.first
          expect(item.total).to have_content("$15.00")
        end
      end
    end
  end

  context "order notes" do
    context "buyer" do
      let!(:user)       { create(:user, organizations: [buyer]) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_order_path(order)
      end

      it "can not access the path" do
        expect(page.status_code).to eq(404)
      end
    end

    context "seller" do
      let!(:user)       { create(:user, organizations: [seller]) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_order_path(order)
      end

      it "can not see order notes" do
        expect(page).to_not have_field("Notes")
      end
    end


    context "market manager" do
      let!(:user)       { create(:user, managed_markets: [market]) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_order_path(order)
      end

      it "saves a note on the order" do
        fill_in "Notes", with: "This is a test note"
        click_button "Save Notes"

        expect(page).to have_content("Order successfully updated")
        expect(find_field("Notes")).to have_content("This is a test note")
      end
    end

    context "admin" do
      let!(:user)       { create(:user, :admin) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_order_path(order)
      end

      it "saves a note on the order" do
        fill_in "Notes", with: "This is a test note"
        click_button "Save Notes"

        expect(page).to have_content("Order successfully updated")
        expect(find_field("Notes")).to have_content("This is a test note")
      end
    end
  end
end
