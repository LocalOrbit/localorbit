require 'spec_helper'

describe AttemptCreditCardPurchase do
  let!(:market)      { create(:market) }
  let!(:user)        { create(:user) }
  let!(:buyer)       { create(:organization) }
  let!(:product)     { create(:product, :sellable, organization: buyer) }
  let!(:credit_card) { create(:bank_account, :credit_card, bankable: buyer, balanced_uri: "/balanced-credit-card-uri") }
  let!(:cart)        { create(:cart, organization: buyer, market: market) }
  let!(:cart_item)   { create(:cart_item, product: product, cart: cart, quantity: 10)}
  let!(:order)       { create(:order, :with_items) }
  let(:params)       { { "payment_method" => "purchase order"} }

  let!(:balanced_customer) { double("balanced customer", debit: balanced_debit) }
  let!(:balanced_debit)    { double("balanced debit", uri: "/balanced-debit-uri") }

  subject {
    class OrganizerWrapper
      include Interactor::Organizer
      organize [AttemptCreditCardPurchase]
    end

    OrganizerWrapper.perform(buyer: user, order: order, order_params: params, cart: cart)
  }

  context "purchase order" do
    let(:params) { { "payment_method" => "purchase order" } }
    it "noop's" do
      expect(subject).to be_success
    end
  end

  context "credit card" do
    let!(:params) { { "payment_method" => "credit card", "credit_card" => "#{credit_card.id}" } }

    before do
      allow(Balanced::Customer).to receive(:find).and_return(balanced_customer)
    end

    context "valid credit card" do
      context "successfully creates a debit" do
        it "creates a payment record" do
          expect {
            subject
          }.to change {
            Payment.all.count
          }.from(0).to(1)

          expect(subject.context).to include(:payment)
        end

        it "creates a hold for the order amount" do
          expect(subject).to be_success
          expect(balanced_customer).to have_received(:debit).with(amount: (cart.total*100).to_i, description: "#{market.name} purchase", source_uri: credit_card.balanced_uri)
        end
      end

      context "fails to create a debit" do
        before do
          expect(balanced_customer).to receive(:debit).and_raise(RuntimeError)
        end

        it "returns as a failure" do
          expect(subject).to be_failure
        end

        it "does not create a payment record" do
          subject

          expect(Payment.all.count).to eql(0)
        end
      end
    end

    context "invalid credit card" do
      let!(:params) { { "payment_method" => "credit card", "credit_card" => "0" } }

      before do
        allow(Balanced::Customer).to receive(:find).and_raise(Exception)
      end

      it "returns as a failure" do
        expect(subject).to be_failure
      end
    end
  end
end
