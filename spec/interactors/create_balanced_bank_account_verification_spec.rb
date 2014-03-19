require "spec_helper"

describe CreateBalancedBankAccountVerification do
  it "creates a balanced bank account verification" do
    bank_account = build(:bank_account)
    balanced_bank_account = double(:balanced_bank_account)
    verification = double(:verification, uri: "/balanced/uri")

    expect(balanced_bank_account).to receive(:verify) { verification }

    expect {
      CreateBalancedBankAccountVerification.perform(bank_account: bank_account, balanced_bank_account: balanced_bank_account)
    }.to change {
      bank_account.balanced_verification_uri
    }.from(nil).to("/balanced/uri")
  end
end
