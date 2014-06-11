require 'spec_helper'

describe BankAccount do
  context "validations" do
    let!(:organization) { create(:organization) }

    it "does not allow duplication accounts" do
      create(:bank_account, account_type: 'visa', last_four: '1234', bankable: organization)

      subject = BankAccount.new(bankable: organization, account_type: 'visa', last_four: '1234')
      expect(subject).to have(1).errors_on(:bankable)

      subject = BankAccount.new(bankable: organization, account_type: 'visa', last_four: '1235')
      expect(subject).to be_valid
    end

    it "does not check soft deleted bank accounts when checking for duplications" do
      create(:bank_account, account_type: 'visa', last_four: '1234', bankable: organization, deleted_at: Time.current)

      subject = BankAccount.new(bankable: organization, account_type: 'visa', last_four: '1234')
      expect(subject).to be_valid
    end
  end
end
