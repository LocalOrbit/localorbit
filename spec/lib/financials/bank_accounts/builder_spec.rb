require 'spec_helper'

describe Financials::BankAccounts::Builder do
  subject(:builder) { described_class }

  describe ".creditable_bank_accounts" do
    let!(:account1) { create(:bank_account, :savings, bank_name: "Alpha") }
    let!(:account2) { create(:bank_account, :checking, bank_name: "Beta") }
    let(:bank_accounts) { [account1,account2] }

    it "generates an array of name/id tuples suitable for use in Rails helpers for SELECT form elements" do
      options = builder.options_for_select(bank_accounts: bank_accounts)
      expect(options).to eq([
        [account1.display_name, account1.id],
        [account2.display_name, account2.id]
      ])
    end
  end
    
end
