describe AddBankAccountToManagedStripeAccount do
  subject { described_class }
  before { VCR.turn_off! }
  after { VCR.turn_on! }

  let!(:stripe_token) { create_stripe_bank_account_token }
  let!(:bank_account) { create(:bank_account, :checking) }
  let!(:stripe_account) { get_or_create_stripe_account_for_market(create(:market, contact_email: "testing_add_bank_accounts@example.com")) }

  let(:bank_account_params) {
    HashWithIndifferentAccess.new(stripe_tok: stripe_token.id)
  }

  # let(:organization) { create(:organization, :buyer) }

  let(:params) {{
    stripe_account: stripe_account,
    bank_account: bank_account,
    bank_account_params: bank_account_params
  }}

  it "creates a new Stripe Account Bank Account and links it to the given BankAccount" do
    result = subject.perform(params)
    expect(result.success?).to be true


    sid = bank_account.stripe_id
    expect(sid).to be

    binding.pry
    x = Stripe::Account.retrieve(stripe_account.id) # need to reload the stripe account
    ba_list = x.bank_accounts.data
    expect(ba_list).to be
    expect(ba_list.first.id).to eq(sid)
  end
  

end
