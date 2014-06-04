require 'spec_helper'

describe 'Editing an order' do
  let!(:market)          { create(:market, :with_addresses, market_seller_fee: 5, local_orbit_seller_fee: 4) }
  let!(:monday_delivery) { create(:delivery_schedule, day: 1)}
  let!(:seller)          { create(:organization, :seller, markets: [market]) }
  let!(:product)         { create(:product, :sellable, organization: seller)}
  let!(:product2)         { create(:product, :sellable, organization: seller)}

  let!(:buyer)      { create(:organization, :buyer, markets: [market]) }

  let!(:delivery)   { monday_delivery.next_delivery }
  let!(:order_item) { create(:order_item, product: product, quantity: 5, unit_price: 3.00) }
  let!(:order)      { create(:order, market: market, organization: buyer, delivery: delivery, items:[order_item], payment_method: 'ach')}
  let!(:payment)    { create(:payment, :checking, orders: [order], amount: 15.00) }

  context "remove item", :js do
    let(:user) { create(:user, organizations: [buyer]) }

    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
    end

    context "as a buyer" do
      it "returns a 404" do
        visit admin_order_path(order)

        expect(page.status_code).to eql(404)
      end
    end

    context "multiple order items" do
      let!(:order_item2) { create(:order_item, product: product2, quantity: 10, unit_price: 3.00) }

      before do
        order.items << order_item2
        visit admin_order_path(order)
      end

      context "as a seller" do
        let!(:user) { create(:user, organizations: [seller]) }

        it "should not allow removing items" do
          expect(page).to_not have_link "Delete"
        end
      end

      context "as a market manager" do
        let!(:user) { create(:user, managed_markets: [market]) }

        it 'removes an item' do
          expect(UpdateBalancedPurchase).to receive(:perform).and_return(double("interactor", "success?" => true))

          expect(Dom::Order::ItemRow.count).to eq(2)
          expect(Dom::Order::ItemRow.all[0].name).to have_content(order_item.name)
          expect(Dom::Order::ItemRow.all[1].name).to have_content(order_item2.name)

          Dom::Order::ItemRow.first.click_delete

          expect(page).to have_content("Order successfully updated")
          expect(Dom::Order::ItemRow.count).to eq(1)
          expect(Dom::Order::ItemRow.all[0].name).to have_content(order_item2.name)
        end

        it 'updates the order total' do
          expect(UpdateBalancedPurchase).to receive(:perform).and_return(double("interactor", "success?" => true))

          expect(page).to have_content("Grand Total: $45.00")

          Dom::Order::ItemRow.first.click_delete

          expect(page).to have_content("Order successfully updated")
          expect(page).to have_content("Grand Total: $30.00")
        end

        it 'updates the order summary totals' do
          expect(UpdateBalancedPurchase).to receive(:perform).and_return(double("interactor", "success?" => true))

          expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$45.00")

          Dom::Order::ItemRow.first.click_delete

          expect(page).to have_content("Order successfully updated")
          expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$30.00")
        end
      end
    end

    context "single order items" do
      before do
        visit admin_order_path(order)
      end

      context "as a seller" do
        let!(:user) { create(:user, organizations: [seller]) }

        it "should not allow removing items" do
          expect(page).to_not have_link "Delete"
        end
      end

      context "as a market manager" do
        let!(:user) { create(:user, managed_markets: [market]) }

        it 'returns you to the orders list' do
          expect(UpdateBalancedPurchase).to receive(:perform).and_return(double("interactor", "success?" => true))

          Dom::Order::ItemRow.first.click_delete

          expect(page).to have_content("Order successfully updated")
          expect(page.current_path).to eql(admin_orders_path)
        end
      end
    end
  end

  context "mark order delivered", :js do
    let(:user) { create(:user, organizations: [buyer]) }

    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
      visit admin_order_path(order)
    end

    context "as a buyer" do
      it "gives a 404" do
        expect(page.status_code).to eql(404)
      end
    end

    context "as a seller" do
      let!(:user) { create(:user, organizations: [seller]) }

      it "marks all items delivered" do
        expect(Dom::Order::ItemRow.first.delivery_status).to eql('Pending')

        click_button 'Mark all delivered'

        expect(Dom::Order::ItemRow.first.delivery_status).to eql('Delivered')
        expect(page).to_not have_button("Mark all delivered")
      end
    end

    context "as a market manager" do
      let!(:user) { create(:user, managed_markets: [market]) }

      it "marks all items delivered" do
        expect(Dom::Order::ItemRow.first.delivery_status).to eql('Pending')

        click_button 'Mark all delivered'

        expect(Dom::Order::ItemRow.first.delivery_status).to eql('Delivered')
        expect(page).to_not have_button("Mark all delivered")
      end
    end

    context "as an admin" do
      let!(:user) { create(:user, :admin) }

      it "marks all items delivered" do
        expect(Dom::Order::ItemRow.first.delivery_status).to eql('Pending')

        click_button 'Mark all delivered'

        expect(Dom::Order::ItemRow.first.delivery_status).to eql('Delivered')
        expect(page).to_not have_button("Mark all delivered")
      end
    end
  end

  context "quantity delivered" do
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

      it "should not change delivery status on an item without a delivery quantity set" do
        visit admin_order_path(order)

        item = Dom::Order::ItemRow.first
        expect(item.total).to have_content("$15.00")
        expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$15.00")

        click_button "Update quantities"

        item = Dom::Order::ItemRow.first
        expect(item.total).to have_content("$15.00")
        expect(item.delivery_status).to eql("Pending")
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

        it "sets the delivery status to 'delivered'" do
          subject

          expect(Dom::Order::ItemRow.first.delivery_status).to eql("Delivered")
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

        it "sets the delivery status to 'delivered'" do
          subject

          expect(Dom::Order::ItemRow.first.delivery_status).to eql("Delivered")
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
          expect(Dom::Order::ItemRow.first.delivery_status).to eql("Pending")
        end

        it "shows an error for non-numerical values" do
          item = Dom::Order::ItemRow.first
          item.set_quantity_delivered("bad")
          click_button "Update quantities"

          expect(page).to have_content("is not a number")
          expect(Dom::Order::ItemRow.first.delivery_status).to eql("Pending")
        end

        it "shows an error for insanely large numbers" do
          item = Dom::Order::ItemRow.first
          item.set_quantity_delivered("2147483648")
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

      it "should not change delivery status on an item without a delivery quantity set" do
        visit admin_order_path(order)

        item = Dom::Order::ItemRow.first
        expect(item.total).to have_content("$15.00")
        expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$15.00")

        click_button "Update quantities"

        item = Dom::Order::ItemRow.first
        expect(item.total).to have_content("$15.00")
        expect(item.delivery_status).to eql("Pending")
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

        it "sets the delivery status to 'delivered'" do
          subject

          expect(Dom::Order::ItemRow.first.delivery_status).to eql("Delivered")
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

        it "sets the delivery status to 'delivered'" do
          subject

          expect(Dom::Order::ItemRow.first.delivery_status).to eql("Delivered")
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
          expect(Dom::Order::ItemRow.first.delivery_status).to eql("Pending")
        end

        it "shows an error for non-numerical values" do
          item = Dom::Order::ItemRow.first
          item.set_quantity_delivered("bad")
          click_button "Update quantities"

          expect(page).to have_content("is not a number")
          expect(page).to_not have_content("failed to update your payment")
          expect(Dom::Order::ItemRow.first.delivery_status).to eql("Pending")
        end

        it "shows an error for insanely large numbers" do
          item = Dom::Order::ItemRow.first
          item.set_quantity_delivered("2147483648")
          click_button "Update quantities"

          expect(page).to have_content("must be less than 2147483647")
          expect(page).to_not have_content("failed to update your payment")
          expect(Dom::Order::ItemRow.first.delivery_status).to eql("Pending")
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
