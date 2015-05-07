require "spec_helper"

describe "Checking Out using Stripe payment provider", :js do
  let!(:user) { create(:user) }
  let!(:other_buying_user) {  create(:user) }
  let!(:buyer) { create(:organization, :single_location, :buyer, users: [user, other_buying_user]) }
  let!(:credit_card)  { create(:bank_account, :credit_card, bankable: buyer) }
  let!(:bank_account) { create(:bank_account, :checking, :verified, bankable: buyer) }

  let!(:fulton_farms) { create(:organization, :seller, :single_location, name: "Fulton St. Farms", users: [create(:user), create(:user)]) }
  let!(:ada_farms) { create(:organization, :seller, :single_location, name: "Ada Farms", users: [create(:user)]) }

  let(:payment_provider) { "stripe" }
  # let(:payment_provider) { "balanced" }
  let(:market_manager) { create(:user) }
  let(:market) { create(:market, :with_addresses, organizations: [buyer, fulton_farms, ada_farms], managers: [market_manager], payment_provider: payment_provider) }
  let(:delivery_schedule) { create(:delivery_schedule, :percent_fee,  market: market, day: 5) }
  let(:delivery_day) { DateTime.parse("May 9, 2014, 11:00:00") }
  let(:delivery) do
    create(:delivery,
           delivery_schedule: delivery_schedule,
           deliver_on: delivery_day,
           cutoff_time: delivery_day - delivery_schedule.order_cutoff.hours
    )
  end

  # Fulton St. Farms
  let!(:bananas) { create(:product, :sellable, name: "Bananas", organization: fulton_farms) }
  let!(:bananas_lot) { create(:lot, product: bananas, quantity: 100) }
  let!(:bananas_price_buyer_base) do
    create(:price, market: market, product: bananas, min_quantity: 1, organization: buyer, sale_price: 0.50)
  end

  let!(:kale) { create(:product, :sellable, name: "Kale", organization: fulton_farms) }
  let!(:kale_lot) { kale.lots.first.update_attribute(:quantity, 100) }
  let!(:kale_price_tier1) do
    create(:price, market: market, product: kale, min_quantity: 4, sale_price: 2.50)
  end

  let!(:kale_price_tier2) do
    create(:price, market: market, product: kale, min_quantity: 6, sale_price: 1.00)
  end

  # Ada Farms
  let!(:potatoes) { create(:product, :sellable, name: "Potatoes", organization: ada_farms) }
  let!(:potatoes_lot) { create(:lot, product: potatoes, quantity: 100) }

  let!(:beans) { create(:product, :sellable, name: "Beans", organization: ada_farms) }

  let!(:cart) { create(:cart, market: market, organization: buyer, user: user, location: buyer.locations.first, delivery: delivery) }
  let!(:cart_bananas) { create(:cart_item, cart: cart, product: bananas, quantity: 10) }
  let!(:cart_potatoes) { create(:cart_item, cart: cart, product: potatoes, quantity: 5) }
  let!(:cart_kale) { create(:cart_item, cart: cart, product: kale, quantity: 20) }

  def cart_link
    Dom::CartLink.find!
  end

  before do
    VCR.turn_off!
    Timecop.travel("May 5, 2014")
  end

  after do
    Timecop.return
    VCR.turn_on!
  end

  def checkout
    click_button "Place Order"
  end

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)

    # NOTE: the behavior of clicking the cart link will change
    # once the cart preview has been built. See
    # https://www.pivotaltracker.com/story/show/67553382
    cart_link.node.click

    expect(page).to have_content("Your Order")
    expect(page).to have_content("Bananas")
    expect(page).to have_content("Kale")
    expect(page).to have_content("Potatoes")
  end

  # context "via purchase order" do
  #   before do
  #     choose "Pay by Purchase Order"
  #     fill_in "PO Number", with: "12345"
  #   end
  #
  #   it "displays copy about the order" do
  #     checkout
  #     expect(page).to have_content("You will receive a confirmation email with details of your order and a link to track its progress")
  #     expect(page).to have_content("If you have any questions, please let us know")
  #   end
  #
  #   context "reviewing the order after checkout" do
  #     it "links to the order to review" do
  #       checkout
  #
  #       click_link "Review Order"
  #
  #       expect(page).to have_content("Order info")
  #       expect(page).to have_content("Bananas")
  #       expect(page).to have_content("Potatoes")
  #       expect(page).to have_content("Kale")
  #     end
  #
  #     context "after delivery" do
  #       it "shows quantity delivered along side quantity ordered" do
  #         checkout
  #
  #         # Find the current order:
  #         order = if page.find("a.review-order")["href"] =~ /\/orders\/(\d+)/
  #                   order_id = $1 
  #                   order = Order.find(order_id)
  #                 else
  #                   raise "Couldn't extract order id from 'Review Order' button"
  #                 end
  #
  #         # Updated delivered quantities:
  #         order.items.find_by(name: "Kale").update(quantity_delivered: "18.3".to_d)
  #         order.items.find_by(name: "Potatoes").update(quantity_delivered: "5".to_d)
  #         order.items.find_by(name: "Bananas").update(quantity_delivered: "12.25".to_d)
  #         order.save! # force an update
  #
  #         # Review the order:
  #         click_link "Review Order"
  #         expect(page).to have_content("Order info")
  #
  #         # See all the quantities are proper:
  #         verify_each(Dom::Order::ItemRow, [
  #           { name: "Kale from Fulton St. Farms",    quantity_ordered_readonly: "20", quantity_delivered_readonly:  "18.3", total: "$18.30" },
  #           { name: "Potatoes from Ada Farms",       quantity_ordered_readonly:  "5", quantity_delivered_readonly:     "5", total: "$15.00" },
  #           { name: "Bananas from Fulton St. Farms", quantity_ordered_readonly: "10", quantity_delivered_readonly: "12.25", total: "$6.13"  },
  #         ], find_by: :name)
  #
  #         expect(page).to have_content("Delivery Fees: $9.86")
  #         expect(page).to have_content("Grand Total: $49.28")
  #       end
  #     end
  #   end
  #
  #   it "sends the buyer an email about the order" do
  #     checkout
  #
  #     [user, other_buying_user].each do |user|
  #       sign_out
  #       sign_in_as(user)
  #       open_email(user.email)
  #
  #       expect(current_email).to have_subject("Thank you for your order")
  #       expect(current_email).to have_body_text("Thank you for your order through #{market.name}")
  #
  #       expect(current_email).to have_body_text("Product Total")
  #       expect(current_email).to have_body_text("Delivery Fee")
  #       expect(current_email).not_to have_body_text("Discount")
  #
  #       visit_in_email "Review Order"
  #       expect(page).to have_content("Order info")
  #       expect(page).to have_content("Items for Delivery")
  #     end
  #   end
  #
  #   it "sends the seller email about the order" do
  #     checkout
  #
  #     fulton_farms.users.each do |seller_user|
  #       sign_out
  #       sign_in_as(seller_user)
  #       open_email(seller_user.email)
  #
  #       expect(current_email).to have_subject("New order on #{market.name}")
  #       expect(current_email.body).to have_content("You have a new order!")
  #       # It does not include content from other sellers
  #       expect(current_email).to have_body_text("Kale")
  #       expect(current_email).to have_body_text("Bananas")
  #       expect(current_email).to_not have_body_text("Potatoes")
  #
  #       expect(current_email).to have_body_text("Product Total")
  #       expect(current_email).not_to have_body_text("Delivery Fee")
  #       expect(current_email).not_to have_body_text("Discount")
  #
  #       expect(current_email.body).to have_content("An order was just placed by #{buyer.name}")
  #
  #       visit_in_email "Check Order Status"
  #       expect(page).to have_content("Order info")
  #       expect(page).to have_content("Items for Delivery")
  #     end
  #
  #     ada_farms.users.each do |seller_user|
  #       sign_out
  #       sign_in_as(seller_user)
  #       open_email(seller_user.email)
  #
  #       expect(current_email).to have_subject("New order on #{market.name}")
  #       expect(current_email.body).to have_content("You have a new order!")
  #       # It does not include content from other sellers
  #       expect(current_email).not_to have_body_text("Kale")
  #       expect(current_email).not_to have_body_text("Bananas")
  #       expect(current_email).to have_body_text("Potatoes")
  #
  #       expect(current_email).to have_body_text("Product Total")
  #       expect(current_email).not_to have_body_text("Delivery Fee")
  #       expect(current_email).not_to have_body_text("Discount")
  #
  #       expect(current_email.body).to have_content("An order was just placed by #{buyer.name}")
  #
  #       visit_in_email "Check Order Status"
  #       expect(page).to have_content("Order info")
  #       expect(page).to have_content("Items for Delivery")
  #     end
  #   end
  #
  #   it "sends the market manager an email about the order" do
  #     checkout
  #
  #     sign_out
  #     sign_in_as(market_manager)
  #     open_email(market.managers[0].email)
  #
  #     expect(current_email).to have_subject("New order on #{market.name}")
  #     expect(current_email.body).to have_content("You've received a new order.")
  #     expect(current_email.body).to have_content("Order Placed By: #{buyer.name}")
  #
  #     expect(current_email).to have_body_text("Kale")
  #     expect(current_email).to have_body_text("Bananas")
  #     expect(current_email).to have_body_text("Potatoes")
  #
  #     expect(current_email).to have_body_text("Product Total")
  #     expect(current_email).to have_body_text("Delivery Fee")
  #     expect(current_email).not_to have_body_text("Discount")
  #
  #     visit_in_email "Check Order Status"
  #     expect(page).to have_content("Order info")
  #     expect(page).to have_content("Items for Delivery")
  #   end
  #
  #   it "displays the ordered products" do
  #     checkout
  #     expect(page).to have_content("Thank you for your order")
  #     bananas_row = Dom::Order::ItemRow.find_by_name("Bananas")
  #     expect(bananas_row.node).to have_content("10 boxes")
  #     expect(bananas_row.node).to have_content("$0.50")
  #     expect(bananas_row.node).to have_content("$5.00")
  #
  #     kale_row = Dom::Order::ItemRow.find_by_name("Kale")
  #     expect(kale_row.node).to have_content("20 boxes")
  #     expect(kale_row.node).to have_content("$1.00")
  #     expect(kale_row.node).to have_content("$20.00")
  #
  #     potatoes_row = Dom::Order::ItemRow.find_by_name("Potatoes")
  #     expect(potatoes_row.node).to have_content("5 boxes")
  #     expect(potatoes_row.node).to have_content("$3.00")
  #     expect(potatoes_row.node).to have_content("$15.00")
  #   end
  #
  #   context "for delivery" do
  #     it "displays the address" do
  #       checkout
  #       expect(page).to have_content("Thank you for your order")
  #       expect(page).to have_content("Your order will be delivered to:")
  #       expect(page).to have_content(buyer.locations.first.address)
  #       expect(page).to have_content("Ann Arbor, MI 48109")
  #     end
  #
  #     it "displays the delivery times" do
  #       checkout
  #       expect(page).to have_content("Thank you for your order")
  #       expect(page).to have_content("Items for delivery on:")
  #       expect(page).to have_content("May 9, 2014 between 7:00AM and 11:00AM")
  #     end
  #   end
  #
  #   context "for pickup" do
  #     let(:delivery_schedule) { create(:delivery_schedule, :buyer_pickup,  market: market, day: 5) }
  #
  #     it "displays the address" do
  #       checkout
  #       expect(page).to have_content("Thank you for your order")
  #
  #       expect(page).to have_content("Your order can be picked up at")
  #       expect(page).to have_content("44 E. 8th St")
  #       expect(page).to have_content("Holland, MI 49423")
  #     end
  #
  #     it "displays the delivery times" do
  #       checkout
  #       expect(page).to have_content("Thank you for your order")
  #
  #       expect(page).to have_content("Items for pickup on:")
  #       expect(page).to have_content("May 9, 2014 between 10:00AM and 12:00PM")
  #     end
  #   end
  #
  #   it "clears out the cart" do
  #     checkout
  #     expect(cart_link.count.text).to eql("0")
  #   end
  #
  #   it "inventory has been exhausted since placing product in cart" do
  #     kale.lots.first.update_attribute(:quantity, 1)
  #     potatoes.lots.each {|lot| lot.update(quantity: 1) }
  #
  #     checkout
  #
  #     expect(cart_link.count.text).to eql("3")
  #     expect(page).to have_content("Your order could not be completed.")
  #
  #     expect(page).to have_content("Unfortunately, there are only 2 Potatoes available")
  #     expect(page).to have_content("Unfortunately, there are only 1 Kale available")
  #   end
  #
  #   it "clearing the cart during checkout preview" do
  #     Dom::Cart::Item.all.each do |item|
  #       item.remove!
  #     end
  #
  #     expect(Dom::CartLink.first).to have_content("Removed from cart!")
  #
  #     expect do
  #       click_button "Place Order"
  #     end.to_not change{
  #       Order.count
  #     }
  #     expect(page).to have_content("Your cart is empty. Please add items to your cart before checking out.")
  #   end
  #
  #   context "with discount" do
  #     context "over the whole order" do
  #       context "less then the order total" do
  #         let(:discount) { create(:discount, code: "15off", discount: "15", type: "fixed") }
  #
  #         before do
  #           cart.update_column(:discount_id, discount.id)
  #         end
  #
  #         it "persists the discount on the order" do
  #           checkout
  #
  #           within(".pseudopod") do
  #             expect(page).to have_content("Item Subtotal $40.00")
  #             expect(page).to have_content("Discount $15.00")
  #             expect(page).to have_content("Delivery Fees $10.00")
  #             expect(page).to have_content("Order Total $35.00")
  #           end
  #         end
  #       end
  #
  #       context "more than order total" do
  #         let(:discount) { create(:discount, code: "50off", discount: "50", type: "fixed") }
  #
  #         before do
  #           cart.update_column(:discount_id, discount.id)
  #         end
  #
  #         it "persists the discount on the order" do
  #           checkout
  #
  #           within(".pseudopod") do
  #             expect(page).to have_content("Item Subtotal $40.00")
  #             expect(page).to have_content("Discount $40.00")
  #             expect(page).to have_content("Delivery Fees $10.00")
  #             expect(page).to have_content("Order Total $10.00")
  #           end
  #         end
  #       end
  #
  #     end
  #
  #     context "over seller items" do
  #       let(:discount) { create(:discount, code: "50percent", discount: "50", type: "percentage", seller_organization_id: ada_farms.id) }
  #
  #       before do
  #         cart.update_column(:discount_id, discount.id)
  #       end
  #
  #       it "persists the discount on the order" do
  #         checkout
  #
  #         within(".pseudopod") do
  #           expect(page).to have_content("Item Subtotal $40.00")
  #           expect(page).to have_content("Discount $7.50")
  #           expect(page).to have_content("Delivery Fees $10.00")
  #           expect(page).to have_content("Order Total $42.50")
  #         end
  #       end
  #     end
  #   end
  # end

  context "via credit card" do
    
    let!(:stripe_customer) { Stripe::Customer.create(
        description: buyer.name,
        metadata: {
          "lo.entity_id" => buyer.id,
          "lo.entity_type" => 'organization'
        }
      ) 
    }

    let!(:stripe_card_token) { create_stripe_token() }

    let!(:stripe_card) { stripe_customer.sources.create(source: stripe_card_token.id) }

    let!(:stripe_account) { 
      get_or_create_stripe_account_for_market(market) 
    }

    before do
      buyer.update(stripe_customer_id: stripe_customer.id)
      credit_card.update(stripe_id: stripe_card.id)
    end

    context "successful payment processing" do
      it "uses a stored credit card" do

        choose "Pay by Credit Card"
        select "Visa", from: "Saved credit cards"

        checkout

        expect(page).to have_content("Thank you for your order")
        expect(page).to have_content("Credit Card")

        order = Order.last
        expect(order.payment_status).to eql("paid")
        expect(order.payments.count).to eql(1)
        expect(order.payments.first.status).to eql("paid")
      end

      # context "cart total of zero" do
      #   let(:discount) { create(:discount, code: "60off", discount: "60", type: "fixed") }
      #
      #   before do
      #     delivery_schedule.update_column(:fee, 0)
      #     cart.update_column(:discount_id, discount.id)
      #   end
      #
      #   it "allows a zero dollar purchase" do
      #     choose "Pay by Credit Card"
      #     select "Visa", from: "Saved credit cards"
      #
      #     checkout
      #
      #     expect(page).to have_content("Thank you for your order")
      #     expect(page).to have_content("Credit Card")
      #
      #     order = Order.last
      #     expect(order.payment_status).to eql("paid")
      #     expect(order.payments.count).to eql(1)
      #     expect(order.payments.first.status).to eql("paid")
      #   end
      # end
    end

    # TODO
    # context "payment processor error" do
    #   before do
    #     expect(balanced_customer).to receive(:debit).and_raise(RuntimeError)
    #   end
    #
    #   it "uses a stored credit card" do
    #     choose "Pay by Credit Card"
    #     select "Visa", from: "Saved credit cards"
    #
    #     checkout
    #
    #     expect(page).to have_content("Your order could not be completed.")
    #     expect(page).to have_content("Payment processor error")
    #
    #     expect(Order.all.count).to eql(0)
    #     expect(Payment.all.count).to eql(0)
    #   end
    # end

    context "unsaved credit card" do
      it "uses the card as a one off transaction" do
        choose "Pay by Credit Card"
        fill_in "Name", with: "John Doe"
        fill_in "Card Number", with: "4000000000000077"
        select "12", from: "Month"
        select "2020", from: "Year"
        fill_in "Security Code", with: "123"

        checkout

        expect(page).to have_content("Thank you for your order")
        expect(page).to have_content("Credit Card")

        order = Order.last
        expect(order.payment_status).to eql("paid")
        expect(order.payments.count).to eql(1)
        expect(order.payments.first.status).to eql("paid")
      end

      it "saves the card for later use" do
        expect(buyer.bank_accounts.visible.count).to eql(2)

        choose "Pay by Credit Card"
        fill_in "Name", with: "John Doe"
        fill_in "Card Number", with: "4000000000000077"
        select "12", from: "Month"
        select "2020", from: "Year"
        fill_in "Security Code", with: "123"
        check "Save credit card for future use"

        checkout

        expect(page).to have_content("Thank you for your order")
        expect(page).to have_content("Credit Card")

        order = Order.last
        expect(order.payment_status).to eql("paid")
        expect(order.payments.count).to eql(1)
        expect(order.payments.first.status).to eql("paid")

        expect(buyer.bank_accounts.visible.count).to eql(3)
      end
    end

    #   context "when the user tries to checkout with a credit card they've already saved", record: :new_episodes do
    #     let!(:credit_card)  { create(:bank_account, :credit_card, name: "John Doe", bank_name: "MasterCard", account_type: "mastercard", bankable: buyer, last_four: "5100") }
    #
    #     it "uses the bank account that's already saved" do
    #       expect(buyer.bank_accounts.visible.count).to eql(2)
    #
    #       choose "Pay by Credit Card"
    #       fill_in "Name", with: credit_card.name
    #       fill_in "Card Number", with: "5105105105105100"
    #       select "12", from: "Month"
    #       select "2020", from: "Year"
    #       fill_in "Security Code", with: "123"
    #
    #       check "Save credit card for future use"
    #
    #       checkout
    #
    #       expect(page).to have_content("Thank you for your order")
    #       expect(page).to have_content("Credit Card")
    #
    #       order = Order.last
    #       expect(order.payment_status).to eql("paid")
    #       expect(order.payments.count).to eql(1)
    #       expect(order.payments.first.status).to eql("paid")
    #
    #       # The entered credit card doesn't get saved in this case
    #       expect(buyer.bank_accounts.visible.count).to eql(2)
    #     end
    #   end
    # end
  end

  # context "via ACH" do
  #   let!(:balanced_debit)  { double("balanced debit", uri: "/balanced-debit-uri") }
  #   let!(:balanced_customer) { double("balanced customer", debit: balanced_debit) }
  #
  #   before do
  #     allow(Balanced::Customer).to receive(:find).and_return(balanced_customer)
  #   end
  #
  #   context "successful payment processing" do
  #     it "uses a stored bank account" do
  #       choose "Pay by ACH"
  #       select "LMCU", from: "Account"
  #
  #       checkout
  #
  #       expect(page).to have_content("Thank you for your order")
  #       expect(page).to have_content("ACH")
  #
  #       order = Order.last
  #       expect(order.payment_status).to eql("pending")
  #       expect(order.payments.count).to eql(1)
  #       expect(order.payments.first.status).to eql("pending")
  #     end
  #
  #     context "cart total of zero" do
  #       let(:discount) { create(:discount, code: "60off", discount: "60", type: "fixed") }
  #
  #       before do
  #         delivery_schedule.update_column(:fee, 0)
  #         cart.update_column(:discount_id, discount.id)
  #       end
  #
  #       it "allows a zero dollar purchase" do
  #         choose "Pay by ACH"
  #         select "LMCU", from: "Account"
  #
  #         checkout
  #
  #         expect(page).to have_content("Thank you for your order")
  #         expect(page).to have_content("ACH")
  #
  #         order = Order.last
  #         expect(order.payment_status).to eql("paid")
  #         expect(order.payments.count).to eql(1)
  #         expect(order.payments.first.status).to eql("paid")
  #       end
  #     end
  #   end
  #
  #   context "payment processor error" do
  #     before do
  #       expect(balanced_customer).to receive(:debit).and_raise(RuntimeError)
  #     end
  #
  #     it "uses a stored bank account" do
  #       choose "Pay by ACH"
  #       select "LMCU", from: "Account"
  #
  #       checkout
  #
  #       expect(page).to have_content("Your order could not be completed.")
  #       expect(page).to have_content("Payment processor error")
  #
  #       expect(Order.all.count).to eql(0)
  #       expect(Payment.all.count).to eql(0)
  #     end
  #   end
  # end

  # context "payment method availability" do
  #   context "enabled at market" do
  #     context "enabled at organization" do
  #       before do
  #         visit cart_path
  #       end
  #
  #       it "should show purchase order payment option on the checkout page" do
  #         expect(page).to have_content("Pay by Purchase Order")
  #       end
  #
  #       it "should show credit card payment option on the checkout page" do
  #         expect(page).to have_content("Pay by Credit Card")
  #       end
  #
  #       it "should show ach payment option on the checkout page" do
  #         expect(page).to have_content("Pay by ACH")
  #       end
  #     end
  #
  #     context "disabled at organization" do
  #       it "should not show purchase order payment option on the checkout page" do
  #         buyer.update(allow_purchase_orders: false)
  #         visit cart_path
  #
  #         expect(page).to_not have_content("Pay by Purchase Order")
  #       end
  #
  #       it "should not show credit card payment option on the checkout page" do
  #         buyer.update(allow_credit_cards: false)
  #         visit cart_path
  #
  #         expect(page).to_not have_content("Pay by Credit Card")
  #       end
  #
  #       it "should not show ach payment option on the checkout page" do
  #         buyer.update(allow_ach: false)
  #         visit cart_path
  #
  #         expect(page).to_not have_content("Pay by ACH")
  #       end
  #     end
  #   end
  #
  #   context "disabled at market" do
  #     context "enabled at organization" do
  #       it "should not show purchase order payment option on the checkout page" do
  #         market.update(allow_purchase_orders: false)
  #         visit cart_path
  #
  #         expect(page).to_not have_content("Pay by Purchase Order")
  #       end
  #
  #       it "should not show credit card payment option on the checkout page" do
  #         market.update(allow_credit_cards: false)
  #         visit cart_path
  #
  #         expect(page).to_not have_content("Pay by Credit Card")
  #       end
  #
  #       it "should not show ACH payment option on the checkout page" do
  #         market.update(allow_ach: false)
  #         visit cart_path
  #
  #         expect(page).to_not have_content("Pay by ACH")
  #       end
  #     end
  #
  #     context "disabled at organization" do
  #       it "should not show purchase order payment option on the checkout page" do
  #         market.update(allow_purchase_orders: false)
  #         buyer.update(allow_purchase_orders: false)
  #         visit cart_path
  #
  #         expect(page).to_not have_content("Pay by Purchase Order")
  #       end
  #
  #       it "should not show credit card payment option on the checkout page" do
  #         market.update(allow_credit_cards: false)
  #         buyer.update(allow_credit_cards: false)
  #         visit cart_path
  #
  #         expect(page).to_not have_content("Pay by Credit Card")
  #       end
  #
  #       it "should not show ach payment option on the checkout page" do
  #         market.update(allow_ach: false)
  #         buyer.update(allow_ach: false)
  #         visit cart_path
  #
  #         expect(page).to_not have_content("Pay by ACH")
  #       end
  #     end
  #   end
  # end
end
