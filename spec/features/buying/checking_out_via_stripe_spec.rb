require "spec_helper"

describe "Checking Out using Stripe payment provider", :js do
  let!(:user) { create(:user) }
  let!(:other_buying_user) {  create(:user) }
  let!(:buyer) { create(:organization, :single_location, :buyer, users: [user, other_buying_user]) }
  let!(:credit_card)  { create(:bank_account, :credit_card, bankable: buyer, stripe_id: 'fake stripe id') }
  let!(:bank_account) { create(:bank_account, :checking, :verified, bankable: buyer, stripe_id: 'another fake stripe id') }

  let!(:fulton_farms) { create(:organization, :seller, :single_location, name: "Fulton St. Farms", users: [create(:user), create(:user)]) }
  let!(:ada_farms) { create(:organization, :seller, :single_location, name: "Ada Farms", users: [create(:user)]) }

  let(:payment_provider) { "stripe" }
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
  let!(:bananas) { create(:product, name: "Bananas", organization: fulton_farms) }
  let!(:bananas_lot) { create(:lot, product: bananas, quantity: 100) }
  let!(:bananas_price_buyer_base) do
    create(:price, :past_price, market: market, product: bananas, min_quantity: 1, organization: buyer, sale_price: 0.50)
  end

  let!(:kale) { create(:product, :sellable, name: "Kale", organization: fulton_farms) }
  let!(:kale_lot) { kale.lots.first.update_attribute(:quantity, 100) }
  let!(:kale_price_tier1) do
    create(:price, :past_price, market: market, product: kale, min_quantity: 4, sale_price: 2.50)
  end

  let!(:kale_price_tier2) do
    create(:price, :past_price, market: market, product: kale, min_quantity: 6, sale_price: 1.00)
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
        payment = order.payments.first
        expect(payment.status).to eql("paid")
        expect(payment.amount).to eq order.total_cost
        # peek a litle deeper
        expect(payment.stripe_id).to be
        charge = Stripe::Charge.retrieve(payment.stripe_id)
        expect(charge).to be
        expect(charge.amount).to eq Financials::MoneyHelpers.amount_to_cents(payment.amount)

        expect(charge.application_fee).to be
        app_fee = Stripe::ApplicationFee.retrieve(charge.application_fee)
        expect(app_fee).to be
        # This will break if the credit card fee structure for stripe changes:
        expected_fee = (payment.amount * "0.029".to_d) + "0.30".to_d
        expected_fee_in_cents = Financials::MoneyHelpers.amount_to_cents(expected_fee)
        expect(app_fee.amount).to eq expected_fee_in_cents
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
          payment = order.payments.first
          expect(payment.status).to eql("paid")
          expect(payment.amount).to eq "0".to_d
          expect(payment.stripe_id).to eq nil
        end
      end
    end

    context "when charging, and PaymentProvider generates an error" do
      before do
        expect(PaymentProvider::Stripe).to receive(:charge_for_order).and_raise("MAJOR FAIL")
      end

      it "displays an error, and creates no Orders nor Payments" do
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
      it "uses the card as a one off transaction" do
        choose "Pay by Credit Card"
        select "Select a Stored Credit Card", from: "Saved credit cards"

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
        select "Select a Stored Credit Card", from: "Saved credit cards"

        fill_in "Name", with: "John Doe"
        fill_in "Card Number", with: "4000000000000077"
        select "12", from: "Month"
        select "2020", from: "Year"
        fill_in "Security Code", with: "123"
        # check "Save credit card for future use" # TODO: further verification.  This feature is broken as of May 2015, so should it be removed from this test, and/or verified more carefully?

        checkout

        expect(page).to have_content("Thank you for your order")
        expect(page).to have_content("Credit Card")

        order = Order.last
        expect(order.payment_status).to eql("paid")
        expect(order.payments.count).to eql(1)
        expect(order.payments.first.status).to eql("paid")

        expect(buyer.bank_accounts.visible.count).to eql(3)
      end

      context "failing to create a new credit card" do
        it "detects invalid card numbers" do
          num_orders = Order.count

          choose "Pay by Credit Card"
          select "Select a Stored Credit Card", from: "Saved credit cards"

          fill_in "Name", with: "John Doe"
          fill_in "Card Number", with: "4242424242424247"
          select "12", from: "Month"
          select "2020", from: "Year"
          fill_in "Security Code", with: "123"

          checkout

          expect(page).to have_content('Your card number is incorrect.')
          expect(num_orders).to eq Order.count
        end

        it "detects a tokenization error" do
          num_orders = Order.count

          choose "Pay by Credit Card"
          select "Select a Stored Credit Card", from: "Saved credit cards"

          fill_in "Name", with: "John Doe"
          fill_in "Card Number", with: "4242424242424242"
          select "12", from: "Month"
          select "2020", from: "Year"
          fill_in "Security Code", with: "12"
          # check "Save credit card for future use" # TODO: further verification.  This feature is broken as of May 2015, so should it be removed from this test, and/or verified more carefully?

          checkout

          expect(page).to have_content("Your card's security code is invalid.")
          expect(num_orders).to eq Order.count
        end
      end
    end

    context "when the user tries to checkout with a credit card they've already saved", record: :new_episodes do
      let!(:credit_card)  { create(:bank_account, :credit_card, name: "John Doe", bank_name: "MasterCard", account_type: "mastercard", bankable: buyer, last_four: "5100", stripe_id: 'a fake id') }

      it "uses the bank account that's already saved" do
        expect(buyer.bank_accounts.visible.count).to eql(2)

        choose "Pay by Credit Card"
        select "Select a Stored Credit Card", from: "Saved credit cards"

        fill_in "Name", with: credit_card.name
        fill_in "Card Number", with: "5105105105105100"
        select "12", from: "Month"
        select "2020", from: "Year"
        fill_in "Security Code", with: "123"

        # check "Save credit card for future use" # TODO: further verification.  This feature is broken as of May 2015, so should it be removed from this test, and/or verified more carefully?

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

end
