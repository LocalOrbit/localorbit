require "spec_helper"

describe "Editing an order" do
  let!(:market)          { create(:market, :with_addresses, market_seller_fee: 5, local_orbit_seller_fee: 4) }
  let!(:marketLE)        { create(:market, :with_addresses, plan_id:4) }
  let!(:monday_delivery) { create(:delivery_schedule, day: 1) }
  let!(:seller)          { create(:organization, :seller, markets: [market]) }
  let!(:product_lot)     { create(:lot, quantity: 145) }
  let!(:product)         { create(:product, :sellable, organization: seller, lots: [product_lot]) }

  let!(:product2)        { create(:product, :sellable, organization: seller) }

  let!(:buyer)           { create(:organization, :buyer, markets: [market]) }

  let!(:delivery)        { monday_delivery.next_delivery }
  let!(:order_item)      { create(:order_item, product: product, quantity: 5, unit_price: 3.00, payment_status: "pending", delivery_status: "pending") }
  let!(:order_item_lot)  { create(:order_item_lot, quantity: 5, lot: product_lot, order_item: order_item) }
  let!(:order)           { create(:order, market: market, organization: buyer, delivery: delivery, items: [order_item], total_cost: 15.00, payment_provider: PaymentProvider::Stripe.id, payment_method: "credit card") }
  let!(:bank_account)    { create(:bank_account, :checking, :verified, bankable: buyer) }
  let!(:payment)         { create(:payment, :checking, bank_account: bank_account, balanced_uri: "/debit-1", orders: [order], amount: 15.00) }

  def long_name(item)
    "#{item.product.name} from #{item.product.organization.name}"
  end

  def first_order_item
    Dom::Order::ItemRow.find_by_name(long_name(order_item))
  end

  context "remove item", :js do
    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
    end

    context "as a buyer" do
      let(:user) { create(:user, organizations: [buyer]) }

      it "returns a 404" do
        visit admin_order_path(order)
        puts "PATH"
        puts page.current_path
        if not user.is_localeyes_buyer?
          expect(page.status_code).to eql(404)
        end
      end
    end

    context "multiple order items" do
      let!(:order_item2) { create(:order_item, product: product2, quantity: 10, unit_price: 3.00) }

      before do
        order.items << order_item2
        order.save!

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

        context "removes an item" do
          it "removes an item" do
            expect(UpdatePurchase).to receive(:perform).and_return(double("interactor", "success?" => true))

            expect(Dom::Order::ItemRow.count).to eq(2)
            expect(Dom::Order::ItemRow.all.map(&:name)).to include(long_name(order_item), long_name(order_item2))

            first_order_item.click_delete

            expect(page).to have_content("Order successfully updated")
            expect(Dom::Order::ItemRow.count).to eq(1)
            expect(Dom::Order::ItemRow.all.map(&:name)).to eql([long_name(order_item2)])
          end

          it "updates the order total" do
            expect(UpdatePurchase).to receive(:perform).and_return(double("interactor", "success?" => true))

            expect(page).to have_content("Grand Total: $45.00")

            first_order_item.click_delete

            expect(page).to have_content("Order successfully updated")
            expect(page).to have_content("Grand Total: $30.00")
          end

          it "updates the order summary totals" do
            expect(UpdatePurchase).to receive(:perform).and_return(double("interactor", "success?" => true))

            expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$45.00")

            first_order_item.click_delete

            expect(page).to have_content("Order successfully updated")
            expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$30.00")
          end

          it "returns the inventory" do
            expect(UpdatePurchase).to receive(:perform).and_return(double("interactor", "success?" => true))
            expect(product.available_inventory).to eql(145)

            first_order_item.click_delete

            expect(page).to have_content("Order successfully updated")
            expect(product.reload.available_inventory).to eql(150)
          end
        end
      end

      context "as an admin" do
        let!(:user) { create(:user, :admin) }

        context "remove an item" do
          it "removes an item" do
            expect(UpdatePurchase).to receive(:perform).and_return(double("interactor", "success?" => true))

            expect(Dom::Order::ItemRow.count).to eq(2)
            expect(Dom::Order::ItemRow.all.map(&:name)).to include(long_name(order_item), long_name(order_item2))

            first_order_item.click_delete

            expect(page).to have_content("Order successfully updated")
            expect(Dom::Order::ItemRow.count).to eq(1)
            expect(Dom::Order::ItemRow.all.map(&:name)).to eql([long_name(order_item2)])
          end

          it "updates the order total" do
            expect(UpdatePurchase).to receive(:perform).and_return(double("interactor", "success?" => true))

            expect(page).to have_content("Grand Total: $45.00")

            first_order_item.click_delete

            expect(page).to have_content("Order successfully updated")
            expect(page).to have_content("Grand Total: $30.00")
          end

          it "updates the order summary totals" do
            expect(UpdatePurchase).to receive(:perform).and_return(double("interactor", "success?" => true))

            expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$45.00")

            first_order_item.click_delete

            expect(page).to have_content("Order successfully updated")
            expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$30.00")
          end

          it "returns the inventory" do
            expect(UpdatePurchase).to receive(:perform).and_return(double("interactor", "success?" => true))
            expect(product.available_inventory).to eql(145)

            first_order_item.click_delete

            expect(page).to have_content("Order successfully updated")
            expect(product.reload.available_inventory).to eql(150)
          end
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

        it "is not allowed to delete a delivered item" do
          order_item.update(delivery_status: "delivered")
          visit admin_order_path(order)

          expect(Dom::Order::ItemRow.first.node.first(".icon-delete")).to be_nil
        end

        it "returns you to the orders list" do
          expect(UpdatePurchase).to receive(:perform).and_return(double("interactor", "success?" => true))

          first_order_item.click_delete

          expect(page).to have_content("Order successfully updated")
          expect(page.current_path).should include(admin_orders_path)
        end

        it "soft deletes the order" do
          expect(UpdatePurchase).to receive(:perform).and_return(double("interactor", "success?" => true))

          first_order_item.click_delete

          expect(page).to have_content("Order successfully updated")
          expect(order.reload.deleted_at).to_not be_nil
        end

        it "returns the inventory" do
          expect(UpdatePurchase).to receive(:perform).and_return(double("interactor", "success?" => true))
          expect(product.available_inventory).to eql(145)

          first_order_item.click_delete

          expect(page).to have_content("Order successfully updated")
          expect(product.reload.available_inventory).to eql(150)
        end
      end

      context "as an admin" do
        let!(:user) { create(:user, :admin) }

        it "is not allowed to delete a delivered item" do
          order_item.update(delivery_status: "delivered")
          visit admin_order_path(order)

          expect(Dom::Order::ItemRow.first.node.first(".icon-delete")).to be_nil
        end

        it "returns you to the orders list" do
          expect(UpdatePurchase).to receive(:perform).and_return(double("interactor", "success?" => true))

          first_order_item.click_delete

          expect(page).to have_content("Order successfully updated")
          expect(page.current_path).should include(admin_orders_path)
        end

        it "soft deletes the order" do
          expect(UpdatePurchase).to receive(:perform).and_return(double("interactor", "success?" => true))

          first_order_item.click_delete

          expect(page).to have_content("Order successfully updated")
          expect(order.reload.deleted_at).to_not be_nil
        end

        it "returns the inventory" do
          expect(UpdatePurchase).to receive(:perform).and_return(double("interactor", "success?" => true))
          expect(product.available_inventory).to eql(145)

          first_order_item.click_delete

          expect(page).to have_content("Order successfully updated")
          expect(product.reload.available_inventory).to eql(150)
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
        expect(Dom::Order::ItemRow.first.delivery_status).to eql("Pending")

        click_button "Mark all delivered"

        expect(Dom::Order::ItemRow.first.delivery_status).to eql("Delivered")
        expect(page).to_not have_button("Mark all delivered")
      end
    end

    context "as a market manager" do
      let!(:user) { create(:user, managed_markets: [market]) }

      it "marks all items delivered" do
        expect(Dom::Order::ItemRow.first.delivery_status).to eql("Pending")

        click_button "Mark all delivered"

        expect(Dom::Order::ItemRow.first.delivery_status).to eql("Delivered")
        expect(page).to_not have_button("Mark all delivered")
      end

      it "marks items canceled if quantity delivered is set to 0" do
        expect(Dom::Order::ItemRow.first.delivery_status).to eql("Pending")

        Dom::Order::ItemRow.first.set_quantity_delivered(0)
        click_button "Mark all delivered"

        item = Dom::Order::ItemRow.first
        expect(item.delivery_status).to eql("Canceled")
        expect(item.payment_status).to eql("Refunded")
        expect(page).to_not have_button("Mark all delivered")
      end
    end

    context "as an admin" do
      let!(:user) { create(:user, :admin) }

      it "marks all items delivered" do
        expect(Dom::Order::ItemRow.first.delivery_status).to eql("Pending")

        click_button "Mark all delivered"

        expect(Dom::Order::ItemRow.first.delivery_status).to eql("Delivered")
        expect(page).to_not have_button("Mark all delivered")
      end

      it "marks items canceled if quantity delivered is set to 0" do
        expect(Dom::Order::ItemRow.first.delivery_status).to eql("Pending")

        Dom::Order::ItemRow.first.set_quantity_delivered(0)
        click_button "Mark all delivered"

        item = Dom::Order::ItemRow.first
        expect(item.delivery_status).to eql("Canceled")
        expect(item.payment_status).to eql("Refunded")
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
        market.update(sellers_edit_orders:true)
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_order_path(order)
      end

      it "should show quantity delivered fields" do
        expect(page).to have_css(".quantity > input")
      end

      it "should have an update button" do
        expect(page).to have_button("Update quantities")
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

      context "less than ordered" do
        before do
          expect(UpdatePurchase).to receive(:perform).and_return(double("interactor", "success?" => true))
        end

        subject do
          visit admin_order_path(order)

          item = Dom::Order::ItemRow.first
          expect(item.total).to have_content("$15.00")
          expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$15.00")

          item.set_quantity_delivered(2)
          click_button "Update quantities"
        end

        it "updates the item total, grand totals and fees" do
          subject

          item = Dom::Order::ItemRow.first

          expect(item.quantity_delivered).to eq("2")

          expect(item.total).to have_content("$6.00")

          expect(page).to have_content("Grand Total: $6.00")

          expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$6.00")
          expect(Dom::Admin::OrderSummaryRow.first.market_fees).to eql("$0.30")
          # Payment fees WON'T BE UPDATED because this test mocks the call to UpdatePurchase, which since Stripe, is where we invoke the payment fee update code.
          expect(Dom::Admin::OrderSummaryRow.first.net_sale).to eql("$5.46")
        end

        it "does not update the product inventory" do
          expect {
            subject
          }.to_not change {
            product.lots.first.reload.quantity
          }.from(140)
        end

        it "sets the delivery status to 'delivered'" do
          subject

          expect(Dom::Order::ItemRow.first.delivery_status).to eql("Delivered")
        end

        it "clears the orders invoice pdf if it has one" do
          expect(ClearInvoicePdf).to receive(:perform)

          subject
        end
      end

      context "fractional quantity, less than ordered" do

        before do
          expect(UpdatePurchase).to receive(:perform).and_return(double("interactor", "success?" => true))
        end

        subject do
          visit admin_order_path(order)

          item = Dom::Order::ItemRow.first
          expect(item.total).to have_content("$15.00")
          expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$15.00")

          item.set_quantity_delivered(2.3)
          click_button "Update quantities"
        end

        it "updates the item total, grand totals and fees" do
          subject

          item = Dom::Order::ItemRow.first

          expect(item.quantity_delivered).to eq("2.3")

          expect(item.total).to have_content("$6.90")

          expect(page).to have_content("Grand Total: $6.90")

          expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$6.90")
          expect(Dom::Admin::OrderSummaryRow.first.market_fees).to eql("$0.35")
          # Payment fees WON'T BE UPDATED because this test mocks the call to UpdatePurchase, which since Stripe, is where we invoke the payment fee update code.
          expect(Dom::Admin::OrderSummaryRow.first.net_sale).to eql("$6.27") 
        end
      end

      context "more then ordered" do
        before do
          expect(UpdatePurchase).to receive(:perform).and_return(double("interactor", "success?" => true))
        end

        subject do
          visit admin_order_path(order)

          item = Dom::Order::ItemRow.first
          expect(item.total).to have_content("$15.00")
          expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$15.00")
          expect(Dom::Admin::OrderSummaryRow.first.net_sale).to eql("$15.00")

          item.set_quantity_delivered(7)
          click_button "Update quantities"
        end

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
          # Payment fees WON'T BE UPDATED because this test mocks the call to UpdatePurchase, which since Stripe, is where we invoke the payment fee update code.
          expect(Dom::Admin::OrderSummaryRow.first.net_sale).to eql("$19.11")
        end

        it "does not update the product inventory" do
          expect {
            subject
          }.to_not change {
            product.lots.first.reload.quantity
          }.from(140)
        end

        it "sets the delivery status to 'delivered'" do
          subject

          expect(Dom::Order::ItemRow.first.delivery_status).to eql("Delivered")
        end

        it "clears the orders invoice pdf if it has one" do
          expect(ClearInvoicePdf).to receive(:perform)

          subject
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
          expect(UpdatePurchase).to receive(:perform).and_return(double("interactor", "success?" => true))
        end

        subject do
          visit admin_order_path(order)

          item = Dom::Order::ItemRow.first
          expect(item.total).to have_content("$15.00")
          expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$15.00")

          item.set_quantity_delivered(2)
          click_button "Update quantities"
        end

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
          # Payment fees WON'T BE UPDATED because this test mocks the call to UpdatePurchase, which since Stripe, is where we invoke the payment fee update code.
          expect(Dom::Admin::OrderSummaryRow.first.net_sale).to eql("$5.46")
        end

        it "does not update the product inventory" do
          expect {
            subject
          }.to_not change {
            product.lots.first.reload.quantity
          }.from(140)
        end

        it "sets the delivery status to 'delivered'" do
          subject

          expect(Dom::Order::ItemRow.first.delivery_status).to eql("Delivered")
        end

        it "clears the orders invoice pdf if it has one" do
          expect(ClearInvoicePdf).to receive(:perform)

          subject
        end
      end

      context "more then ordered" do
        before do
          expect(UpdatePurchase).to receive(:perform).and_return(double("interactor", "success?" => true))
        end

        subject do
          visit admin_order_path(order)

          item = Dom::Order::ItemRow.first
          expect(item.total).to have_content("$15.00")
          expect(Dom::Admin::OrderSummaryRow.first.gross_total).to eql("$15.00")
          expect(Dom::Admin::OrderSummaryRow.first.net_sale).to eql("$15.00")

          item.set_quantity_delivered(7)
          click_button "Update quantities"
        end

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
          # Payment fees WON'T BE UPDATED because this test mocks the call to UpdatePurchase, which since Stripe, is where we invoke the payment fee update code.
          expect(Dom::Admin::OrderSummaryRow.first.net_sale).to eql("$19.11")
        end

        it "does not update the product inventory" do
          expect {
            subject
          }.to_not change {
            product.lots.first.reload.quantity
          }.from(140)
        end

        it "sets the delivery status to 'delivered'" do
          subject

          expect(Dom::Order::ItemRow.first.delivery_status).to eql("Delivered")
        end

        it "clears the orders invoice pdf if it has one" do
          expect(ClearInvoicePdf).to receive(:perform)

          subject
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
