require 'spec_helper'

describe AddStripeCreditCardToEntity do
  subject { described_class }

  before(:all) { VCR.turn_off! }
  after(:all) { VCR.turn_on! }

  let(:org) { create(:organization) }
  
  let!(:stripe_customer) { create_stripe_customer(organization: org) }
  let!(:stripe_token) { create_stripe_token }

  let(:bank_account_params) {
    HashWithIndifferentAccess.new(
      "bank_name"=>"MasterCard",
      "name"=>"John Doe",
      "last_four"=>"5100",
      "stripe_tok"=>stripe_token.id,
      "account_type"=>"card",
      "expiration_month"=>"5",
      "expiration_year"=>"2020",
      "notes"=>"primary"
    )
  } 

  let(:representative_params) { HashWithIndifferentAccess.new({}) }

  def perform
    subject.perform(
      entity: org, 
      bank_account_params: bank_account_params, 
      representative_params: representative_params)
  end

  it "creates a new bank account and stripe card and hooks them up" do
    expect(org.bank_accounts).to be_empty
    perform

    expect(org.bank_accounts.count).to eq 1
    bank_account = org.bank_accounts.first
    expect(bank_account.stripe_id).to be
    card = stripe_customer.sources.retrieve(bank_account.stripe_id)
    expect(card).to be
  end
end
