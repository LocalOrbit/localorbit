require "spec_helper"

describe BankAccountVerification do
  let(:org) { create(:organization) }
  let(:bank_account) { create(:bank_account, :checking, bankable: org) }
  let(:model) { BankAccountVerification.new }

  before do
    model.bank_account = bank_account
  end

  describe "validations" do
    it "requires 2 amounts" do
      model.valid?
      expect(model.errors[:amount_1]).not_to be_empty
      expect(model.errors[:amount_2]).not_to be_empty
    end
  end

  describe "#save" do
    it "verifies with balanced if valid" do
      model.amount_1 = 1
      model.amount_2 = 2
      expect(VerifyBankAccount).to receive(:perform).with(
        bank_account: model.bank_account,
        verification_params: {amount_1: 1, amount_2: 2}).and_return(double(:interactor, success?: true))
      model.save
    end

    it "does not verify with balanced if invalid" do
      expect(VerifyBankAccount).not_to receive(:perform)
      model.save
    end

    it "returns true if valid and verified" do
      expect(model).to receive(:valid?).and_return(true)
      expect(VerifyBankAccount).to receive(:perform).and_return(double(:interactor, success?: true))
      expect(model.save).to be(true)
    end

    it "returns false if invalid" do
      expect(model).to receive(:valid?).and_return(false)
      expect(model.save).to be(false)
    end

    it "returns false if valid but unverified" do
      expect(model).to receive(:valid?).and_return(true)
      expect(VerifyBankAccount).to receive(:perform).and_return(double(:interactor, success?: false))
      expect(model.save).to be(false)
    end
  end
end