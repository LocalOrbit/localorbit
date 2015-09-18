describe AddBankAccountToManagedStripeAccount do
  subject { described_class }

  let(:stripe_bank_account) { double "stripe bank account", id: 'saba id' }
  let(:bank_accounts_proxy) { double "bank accounts proxy" }
  let(:stripe_account) { double "stripe account", bank_accounts: bank_accounts_proxy }
  let(:bank_account) { double "bank account" }
  let(:bank_account_params) { HashWithIndifferentAccess.new(stripe_tok: "a stripe token") }

  let(:params) {{
    stripe_account: stripe_account,
    bank_account: bank_account,
    bank_account_params: bank_account_params
  }}

  it "creates a new Stripe Account Bank Account and links it to the given BankAccount" do
    expect(bank_accounts_proxy).to receive(:create).with(bank_account: "a stripe token", default_for_currency: true).and_return(stripe_bank_account)
    expect(bank_account).to receive(:update).with(stripe_id: 'saba id', account_role: 'deposit')

    result = subject.perform(params)
    expect(result.success?).to be true
  end
  

end
