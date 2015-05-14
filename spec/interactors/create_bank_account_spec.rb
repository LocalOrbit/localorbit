describe CreateBankAccount do
  subject { described_class }

  let(:bank_account_params) {
    HashWithIndifferentAccess.new(
      "bank_name"=>"MasterCard",
      "name"=>"John Doe",
      "last_four"=>"5100",
      "stripe_tok"=>"a token",
      "account_type"=>"card",
      "expiration_month"=>"5",
      "expiration_year"=>"2020",
      "notes"=>"primary"
    )
  } 

  let(:organization) { create(:organization, :buyer) }

  def perform
    subject.perform(
      bank_account_params: bank_account_params,
      entity: organization
    )
  end

  it "adds a new BankAccount to the given entity, and stashes the new account in the context" do
    result = perform
    expect(result.success?).to be true
    ba = result.bank_account
    expect(ba).to be
    expect(ba).to eq organization.bank_accounts.first

    # make sure it leaves stripe_tok in place in the bank_account_params
    expect(bank_account_params[:stripe_tok]).to eq "a token"
  end
  
  it "fails the interaction on bank account creation error" do
    result = perform
    expect(result.success?).to be true

    result2 = perform
    expect(result2.success?).to be false
    expect(result2.bank_account.valid?).to be false
  end



end
