require 'spec_helper'

describe RollYourOwnMarket do
  subject { described_class }

  # # These exist in add_stripe_credit_card_to_entity_spec so I put 'em in here, but I think it's better without them
  # before(:all) { VCR.turn_off! }
  # after(:all) { VCR.turn_on! }

  let(:mkt) { create(:market) }
  
  let!(:stripe_customer) { create_stripe_customer(organization: mkt) }
  let!(:stripe_token) { create_stripe_token }

  let(:market_params) {
    HashWithIndifferentAccess.new(
      "stripe_tok"=>stripe_token.id,
      "contact_name"=>"Harry Panicles",
      "contact_email"=>"hpanicles@example.com",
      "contact_phone"=>"313-454-1023",
      "name"=>"Walrus Flower",
      "subdomain"=>"walrusflower",
      "pending"=>true,
      "plan_id"=>"2",
    )
  }

  let(:billing_params) {
    HashWithIndifferentAccess.new(
	  	"address"=>"123 Main Street",
	  	"city"=>"Jonesville",
	  	"state"=>"NV",
	  	"country"=>"United States",
	  	"zip"=>"49240"
  	)
  }

  let(:subscription_params) {
    HashWithIndifferentAccess.new(
	  	"plan"=>"GROW",
	  	"plan_price"=>"700.00"
  	)
  }

  let(:bank_account_params) {
    HashWithIndifferentAccess.new(
    	"stripe_tok"=>stripe_token.id,
    )
  }

  def perform
  	subject.perform(
			market_params: market_params, 
			billing_params: billing_params, 
			subscription_params: subscription_params,
			bank_account_params: bank_account_params,
			amount: subscription_params[:plan_price]
  	)
  end

  context "creates new ", vcr: true do
	  it "market" do
	  	results = perform
	  	expect(results.market).to be
	  end

	  it "market address" do
	  	results = perform
	  	expect(results.billing_address).to be
	  end

	  it "stripe customer for market" do
	  	results = perform
	  	expect(results.stripe_customer).to be
	  end

	  it "plan subscription" do
	  	results = perform
	  	expect(results.subscription).to be
	  end

	  it "bank account" do
	  	results = perform
	  	expect(results.bank_account).to be
	  end

	  it "payment record in LO" do
	  	results = perform
	  	expect(results.payment).to be
	  end
	end
end
