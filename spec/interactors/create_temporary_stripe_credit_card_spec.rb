require "spec_helper"

describe CreateTemporaryStripeCreditCard do

  before :all do
    VCR.turn_off!  # CUT! CUT! CUT! 
  end

  after :all do
    VCR.turn_on!
  end

  after do
    cleanup_stripe_objects
  end

  let(:cart)      { create(:cart, organization: org) }
  let(:org)       { create(:organization, name: "[Test] temp credit cards") }
  let(:order) { create(:order) }
  let(:payment_method) { "credit card" }
  let(:order_params) {
    HashWithIndifferentAccess.new(
      payment_method: payment_method,
      credit_card: HashWithIndifferentAccess.new(
        account_type: "visa",
        last_four: "1111",
        bank_name: "House of Test",
        name: "My Test Visa",
        expiration_month: "06",
        expiration_year: "2016"
      )
    )
  }

  context "integration tests" do
    subject { described_class }

    context "when Stripe customer already associated with the entity" do

      let(:stripe_card_token) {
        Stripe::Token.create(
          card: {
            number: "4012888888881881", 
            exp_month: 5, 
            exp_year: 2016, 
            cvc: "314"
          }
        )
      }

      let!(:stripe_customer) { 
        create_stripe_customer(organization: org)
      }

      before do
        order_params[:credit_card][:stripe_tok] = stripe_card_token.id
      end

      it "creates a new BankAccount and Stripe::Customer" do
        result = subject.perform(order_params: order_params, cart: cart, order: order)
        expect(result.success?).to be true
        
        bank_account_id = result.context[:order_params]["credit_card"]["id"]
        expect(bank_account_id).to be

        bank_account = BankAccount.find(bank_account_id)
        expect(bank_account).to be
        expect(bank_account.bankable).to eq org
        expect(bank_account.deleted_at).to be
        expect(bank_account.stripe_id).to be

        card = stripe_customer.sources.retrieve(bank_account.stripe_id)
        expect(card).to be

      end
    end


    context "non-CC payment" do
      let(:order_params) {
        HashWithIndifferentAccess.new(
          payment_method: "other",
        )
      }

      it "doesn't process" do
        result = subject.perform(order_params: order_params, cart: cart, order: order)
        expect(result.success?).to be true
      end
    end

    context "utilizing an existing card or account" do
      before do
        order_params[:credit_card][:id] = "123"
        order_params[:credit_card][:stripe_tok] = "something"
      end
      it "doesn't process" do
        result = subject.perform(order_params: order_params, cart: cart, order: order)
        expect(result.success?).to be true
      end
    end

    context "bank account already exists for given card info" do
      let!(:bank_account) { create(:bank_account, :credit_card,
                                  bankable: org,
                                  last_four: "1111",
                                  bank_name: "House of Test",
                                  name: "My Test Visa") }
      
      it "sets that bank account" do
        order_params[:credit_card][:stripe_tok] = "not matter"
        result = subject.perform(order_params: order_params, cart: cart, order: order)
        expect(result.success?).to be true

        bank_account_id = result.context[:order_params]["credit_card"]["id"]
        expect(bank_account_id).to eq bank_account.id
      end
    end
  end

end
