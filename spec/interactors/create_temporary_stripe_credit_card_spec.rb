require "spec_helper"

describe CreateTemporaryStripeCreditCard do

  before :all do
    VCR.turn_off!  # CUT! CUT! CUT! 
  end

  after :all do
    VCR.turn_on!
  end

  def delete_later(obj)
    @objects_to_delete ||= []
    @objects_to_delete << obj
  end

  after do
    (@objects_to_delete || []).each do |obj|
      begin
        obj.delete
      rescue Exception => e
        puts "(Error while trying to delete #{obj.inspect}: #{e.message})"
      end 
    end
  end


  context "integration tests" do
    subject { described_class }

    context "when Stripe customer already associated with the entity" do
      let!(:org)       { create(:organization, name: "Customer for make test of temp credit cards") }
      let!(:cart)      { create(:cart, organization: org) }
      let!(:order) { create(:order) }

      let(:order_params) {
        HashWithIndifferentAccess.new(
          payment_method: "credit card",
          credit_card: HashWithIndifferentAccess.new(
            account_type: "visa",
            last_four: "1111",
            bank_name: "House of Test",
            name: "My Test Visa",
            expiration_month: "06",
            expiration_year: "2016",
            stripe_tok: stripe_card_token.id
          )
        )
      }

      let!(:stripe_card_token) {
        Stripe::Token.create(
          card: {
            number: "4012888888881881", 
            exp_month: 5, 
            exp_year: 2016, 
            cvc: "314"
          }
        )
      }

      let!(:stripe_customer) { Stripe::Customer.create(
          description: org.name,
          metadata: {
            "lo.entity_id" => org.id,
            "lo.entity_type" => 'organization'
          }
        ) 
      }

      before do
        org.update(stripe_customer_id: stripe_customer.id)
        delete_later stripe_customer
        delete_later stripe_card_token
      end

      it "creates a new BankAccount and Stripe::Customer" do
        binding.pry
        
        result = subject.perform(order_params: order_params, cart: cart, order: order)
        binding.pry
        
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
  end
end
