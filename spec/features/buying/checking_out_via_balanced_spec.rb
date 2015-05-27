require "spec_helper"

describe "Checking Out via Balanced", :js, :vcr do
  let!(:user) { create(:user) }
  let!(:other_buying_user) {  create(:user) }
  let!(:buyer) { create(:organization, :single_location, :buyer, users: [user, other_buying_user]) }
  let!(:credit_card)  { create(:bank_account, :credit_card, bankable: buyer, balanced_uri: 'a fake uri') }
  let!(:bank_account) { create(:bank_account, :checking, :verified, bankable: buyer, balanced_uri: 'another fake uri') }

  let!(:fulton_farms) { create(:organization, :seller, :single_location, name: "Fulton St. Farms", users: [create(:user), create(:user)]) }
  let!(:ada_farms) { create(:organization, :seller, :single_location, name: "Ada Farms", users: [create(:user)]) }

  let(:market_manager) { create(:user) }
  # TODO: use payment_provider constants
  let(:market) { create(:market, :with_addresses, 
                        payment_provider: 'balanced',
                        organizations: [buyer, fulton_farms, ada_farms], managers: [market_manager]) }
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
    Dom::CartLink.first
  end

  before do
    Timecop.travel("May 5, 2014")
  end

  after do
    Timecop.return
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

  context "via credit card" do
    let(:balanced_debit)  { double("balanced debit", uri: "/balanced-debit-uri") }
    let!(:balanced_customer) { double("balanced customer", debit: balanced_debit) }

    before do
      allow(Balanced::Customer).to receive(:find).and_return(balanced_customer)
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

      context "cart total of zero" do
        let(:discount) { create(:discount, code: "60off", discount: "60", type: "fixed") }

        before do
          delivery_schedule.update_column(:fee, 0)
          cart.update_column(:discount_id, discount.id)
        end

        it "allows a zero dollar purchase" do
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
      end
    end

    context "payment processor error" do
      before do
        expect(balanced_customer).to receive(:debit).and_raise(RuntimeError)
      end

      it "uses a stored credit card" do
        choose "Pay by Credit Card"
        select "Visa", from: "Saved credit cards"

        checkout

        expect(page).to have_content("Your order could not be completed.")
        expect(page).to have_content("Payment processor error")

        expect(Order.all.count).to eql(0)
        expect(Payment.all.count).to eql(0)
      end
    end

    context "unsaved credit card" do
      context "successfully entering credit card" do
        before do
          expect(balanced_customer).to receive(:add_card)
        end

        it "uses the card as a one off transaction" do
          choose "Pay by Credit Card"
          fill_in "Name", with: "John Doe"
          fill_in "Card Number", with: "5105105105105100"
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
          fill_in "Card Number", with: "5105105105105100"
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

        context "when the user tries to checkout with a credit card they've already saved", record: :new_episodes do
          let!(:credit_card)  { create(:bank_account, :credit_card, name: "John Doe", bank_name: "MasterCard", account_type: "mastercard", bankable: buyer, last_four: "5100", balanced_uri: 'fake uri') }

          it "uses the bank account that's already saved" do
            expect(buyer.bank_accounts.visible.count).to eql(2)

            choose "Pay by Credit Card"
            fill_in "Name", with: credit_card.name
            fill_in "Card Number", with: "5105105105105100"
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

            # The entered credit card doesn't get saved in this case
            expect(buyer.bank_accounts.visible.count).to eql(2)
          end
        end
      end

      context "failing to create a new credit card" do
        it "detects invalid card numbers" do
          num_orders = Order.count

          choose "Pay by Credit Card"
          fill_in "Name", with: "John Doe"
          fill_in "Card Number", with: "5105105105105107"
          select "12", from: "Month"
          select "2020", from: "Year"
          fill_in "Security Code", with: "123"
          check "Save credit card for future use"

          checkout

          expect(page).to have_content('Card number: "5105105105105107" is not a valid credit card number')
          expect(num_orders).to eq Order.count
        end

        it "detects a tokenization error" do
          num_orders = Order.count

          choose "Pay by Credit Card"
          fill_in "Name", with: "John Doe"
          fill_in "Card Number", with: "4222222222222220"
          select "12", from: "Month"
          select "2020", from: "Year"
          fill_in "Security Code", with: "123"
          check "Save credit card for future use"

          checkout

          expect(page).to have_content('Additional: This transaction was declined by the card issuer. Customer please call bank.')
          expect(num_orders).to eq Order.count
        end
      end
    end
  end

  context "via ACH" do
    let!(:balanced_debit)  { double("balanced debit", uri: "/balanced-debit-uri") }
    let!(:balanced_customer) { double("balanced customer", debit: balanced_debit) }

    before do
      allow(Balanced::Customer).to receive(:find).and_return(balanced_customer)
    end

    context "successful payment processing" do
      it "uses a stored bank account" do
        choose "Pay by ACH"
        select "LMCU", from: "Account"

        checkout

        expect(page).to have_content("Thank you for your order")
        expect(page).to have_content("ACH")

        order = Order.last
        expect(order.payment_status).to eql("pending")
        expect(order.payments.count).to eql(1)
        expect(order.payments.first.status).to eql("pending")
      end

      context "cart total of zero" do
        let(:discount) { create(:discount, code: "60off", discount: "60", type: "fixed") }

        before do
          delivery_schedule.update_column(:fee, 0)
          cart.update_column(:discount_id, discount.id)
        end

        it "allows a zero dollar purchase" do
          choose "Pay by ACH"
          select "LMCU", from: "Account"

          checkout

          expect(page).to have_content("Thank you for your order")
          expect(page).to have_content("ACH")

          order = Order.last
          expect(order.payment_status).to eql("paid")
          expect(order.payments.count).to eql(1)
          expect(order.payments.first.status).to eql("paid")
        end
      end
    end

    context "payment processor error" do
      before do
        expect(balanced_customer).to receive(:debit).and_raise(RuntimeError)
      end

      it "uses a stored bank account" do
        choose "Pay by ACH"
        select "LMCU", from: "Account"

        checkout

        expect(page).to have_content("Your order could not be completed.")
        expect(page).to have_content("Payment processor error")

        expect(Order.all.count).to eql(0)
        expect(Payment.all.count).to eql(0)
      end
    end
  end

  context "payment method availability" do
    context "enabled at market" do
      context "enabled at organization" do
        before do
          visit cart_path
        end

        it "should show purchase order payment option on the checkout page" do
          expect(page).to have_content("Pay by Purchase Order")
        end

        it "should show credit card payment option on the checkout page" do
          expect(page).to have_content("Pay by Credit Card")
        end

        it "should show ach payment option on the checkout page" do
          expect(page).to have_content("Pay by ACH")
        end
      end

      context "disabled at organization" do
        it "should not show purchase order payment option on the checkout page" do
          buyer.update(allow_purchase_orders: false)
          visit cart_path

          expect(page).to_not have_content("Pay by Purchase Order")
        end

        it "should not show credit card payment option on the checkout page" do
          buyer.update(allow_credit_cards: false)
          visit cart_path

          expect(page).to_not have_content("Pay by Credit Card")
        end

        it "should not show ach payment option on the checkout page" do
          buyer.update(allow_ach: false)
          visit cart_path

          expect(page).to_not have_content("Pay by ACH")
        end
      end
    end

    context "disabled at market" do
      context "enabled at organization" do
        it "should not show purchase order payment option on the checkout page" do
          market.update(allow_purchase_orders: false)
          visit cart_path

          expect(page).to_not have_content("Pay by Purchase Order")
        end

        it "should not show credit card payment option on the checkout page" do
          market.update(allow_credit_cards: false)
          visit cart_path

          expect(page).to_not have_content("Pay by Credit Card")
        end

        it "should not show ACH payment option on the checkout page" do
          market.update(allow_ach: false)
          visit cart_path

          expect(page).to_not have_content("Pay by ACH")
        end
      end

      context "disabled at organization" do
        it "should not show purchase order payment option on the checkout page" do
          market.update(allow_purchase_orders: false)
          buyer.update(allow_purchase_orders: false)
          visit cart_path

          expect(page).to_not have_content("Pay by Purchase Order")
        end

        it "should not show credit card payment option on the checkout page" do
          market.update(allow_credit_cards: false)
          buyer.update(allow_credit_cards: false)
          visit cart_path

          expect(page).to_not have_content("Pay by Credit Card")
        end

        it "should not show ach payment option on the checkout page" do
          market.update(allow_ach: false)
          buyer.update(allow_ach: false)
          visit cart_path

          expect(page).to_not have_content("Pay by ACH")
        end
      end
    end
  end
end
