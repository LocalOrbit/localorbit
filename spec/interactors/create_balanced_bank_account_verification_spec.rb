require "spec_helper"

describe CreateBalancedBankAccountVerification do
  context "no verification" do
    it "creates a balanced bank account verification" do
      bank_account = build(:bank_account)
      balanced_bank_account = double(:balanced_bank_account, verification_uri: nil)
      verification = double(:verification, uri: "/balanced/uri")

      expect(balanced_bank_account).to receive(:verify) { verification }

      expect {
        CreateBalancedBankAccountVerification.perform(bank_account: bank_account, balanced_bank_account: balanced_bank_account)
      }.to change {
        bank_account.balanced_verification_uri
      }.from(nil).to("/balanced/uri")
    end
  end

  context "verification exists" do
    it "does not create a new verification" do
      bank_account = build(:bank_account, balanced_verification_uri: "/existing-balanced-uri")
      balanced_bank_account = double(:balanced_bank_account, verification_uri: "/balanced-verification-uri")

      expect {
        CreateBalancedBankAccountVerification.perform(bank_account: bank_account, balanced_bank_account: balanced_bank_account)
      }.to_not change {
        bank_account.balanced_verification_uri
      }.from("/existing-balanced-uri")
    end
  end
end
