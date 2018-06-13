require "spec_helper"

describe CreateTemporaryStripeCreditCard do
  subject { described_class }

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
        account_type: "card",
        last_four: "1111",
        bank_name: "Visa",
        name: "John Doe",
        expiration_month: "06",
        expiration_year: "2016"
      )
    )
  }

  context "integration tests" do
    let(:stripe_card_token) { create_stripe_token }

    before :all do
      VCR.turn_off!  # CUT! CUT! CUT!
    end

    after :all do
      VCR.turn_on!
    end


    context "when Stripe customer already associated with the entity" do

      let!(:stripe_customer) { create_stripe_customer(organization: org) }

      before do
        order_params[:credit_card][:stripe_tok] = stripe_card_token.id
      end

      it "creates a new BankAccount and Stripe::Customer::Source" do
        result = subject.perform(order_params: order_params, cart: cart, order: order)
        expect(result.success?).to be true

        bank_account_id = result.context[:order_params]["credit_card"]["id"]
        expect(bank_account_id).to be

        bank_account = BankAccount.find(bank_account_id)
        expect(bank_account).to be
        expect(bank_account.bankable).to eq(org)
        expect(bank_account.deleted_at).to be
        expect(bank_account.stripe_id).to be

        card = stripe_customer.sources.retrieve(bank_account.stripe_id)
        expect(card).to be
      end

      context "bank account already exists with same last four digits" do
        context "and same expiration date" do
          let!(:bank_account) { create(:bank_account, :credit_card,
                                bankable: org,
                                last_four: order_params[:credit_card][:last_four],
                                bank_name: order_params[:credit_card][:bank_name],
                                expiration_month: order_params[:credit_card][:expiration_month],
                                expiration_year: order_params[:credit_card][:expiration_year],
                                name: order_params[:credit_card][:name]) }

          it "sets that bank account" do
            result = subject.perform(order_params: order_params, cart: cart, order: order)
            expect(result.success?).to be true

            bank_account_id = result.context[:order_params][:credit_card][:id]
            expect(bank_account_id).to eq bank_account.id
          end
        end

        context "but different expiration date" do
          let!(:bank_account) { create(:bank_account, :credit_card,
                                bankable: org,
                                last_four: order_params[:credit_card][:last_four],
                                bank_name: order_params[:credit_card][:bank_name],
                                expiration_month: "09",
                                expiration_year: "2032",
                                name: order_params[:credit_card][:name]) }

          it "adds a new bank account" do
            result = subject.perform(order_params: order_params, cart: cart, order: order)
            expect(result.success?).to be true

            bank_account_id = result.context[:order_params][:credit_card][:id]
            expect(bank_account_id).to_not eq bank_account.id
          end
        end
      end
    end

    context "if card creation fails" do
      before do
        order_params[:credit_card][:stripe_tok] = "NO GOOD"
      end

      it "reports an interpreted error to Rollbar and fails the context" do
        expect(Rollbar).to receive(:info)

        result = subject.perform(order_params: order_params, cart: cart, order: order)

        expect(result.success?).to be false
        expect(org.bank_accounts).to be_empty
        expect(result.order.errors.messages[:credit_card]).to be
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
  end
end
