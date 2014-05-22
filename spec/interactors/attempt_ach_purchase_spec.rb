require 'spec_helper'

describe AttemptAchPurchase do
  let!(:user)        { create(:user) }
  let!(:buyer)       { create(:organization, balanced_customer_uri: "/balanced-customer-uri") }
  let!(:product)     { create(:product, :sellable, organization: buyer) }
  let!(:bank_account) { create(:bank_account, :checking, bankable: buyer, balanced_uri: "/balanced-card-uri") }
  let!(:cart)        { create(:cart, organization: buyer) }
  let!(:cart_item)   { create(:cart_item, product: product, cart: cart, quantity: 10)}
  let!(:order)       { create(:order, :with_items) }
  let(:params)       { { "payment_method" => "purchase order"} }

  let(:balanced_debit)  { double("balanced debit", uri: '/balanced-debit-uri') }
  let!(:balanced_customer) { double("balanced customer", debit: balanced_debit) }

  subject {
    class OrganizerWrapper
      include Interactor::Organizer
      organize [AttemptAchPurchase]
    end

    OrganizerWrapper.perform(buyer: user, order: order, order_params: params, cart: cart)
  }

  context "purchase order" do
    let(:params) { { "payment_method" => "purchase order" } }
    it "noop's on perform" do
      expect(subject).to be_success
    end
  end

  context "credit card" do
    let(:params) { { "payment_method" => "credit card" } }
    it "noop's on perform" do
      expect(subject).to be_success
    end
  end

  context "ach" do
    let!(:params) { { "payment_method" => "ach", "bank_account" => "#{bank_account.id}" } }

    before do
      allow(Balanced::Customer).to receive(:find).and_return(balanced_customer)
    end

    context "valid bank account" do
      context "successfully debits bank account" do
        it "creates a payment record" do
          expect {
            subject
          }.to change {
            Payment.all.count
          }.from(0).to(1)

          expect(subject.context).to include(:payment)
          expect(order.reload.payments).to include(subject.context[:payment])
        end

        it "sets the payment method on the order" do
          expect {
            subject
          }.to change {
            order.reload.payment_method
          }.from("purchase order").to("ach")
        end

        it "sets the payment status on the order" do
          expect {
            subject
          }.to change {
            order.reload.payment_status
          }.from("unpaid").to("pending")
        end

        it "creates a debit for the order amount" do
          expect(subject).to be_success
          expect(balanced_customer).to have_received(:debit).with(
            amount: (cart.total*100).to_i,
            source_uri: bank_account.balanced_uri,
            description: "#{cart.market.name} purchase"
          )
        end
      end

      context "fails to debit bank account" do
        before do
          expect(balanced_customer).to receive(:debit).and_raise(RuntimeError)
        end

        it "returns as a failure" do
          expect(subject).to be_failure
        end

        it "does not modify the order" do
          expect {
            subject
          }.to_not change {
            Payment.all.count
          }.from(0)
        end
      end
    end

    context "invalid bank account" do
      let!(:params) { { "payment_method" => "ach", "bank_account" => "0" } }

      before do
        allow(Balanced::Customer).to receive(:debit).and_raise(Exception)
      end

      it "returns as a failure" do
        expect(subject).to be_failure
      end

      it "does not record a payment" do
        expect {
          subject
        }.to_not change {
          Payment.all.count
        }.from(0)
      end
    end
  end
end
