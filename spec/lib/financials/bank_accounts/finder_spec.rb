require 'spec_helper'

describe Financials::BankAccounts::Finder do
  subject(:finder) { described_class }

  include_context "the mini market"

  describe ".creditable_bank_accounts" do
    let!(:cc1) { create(:bank_account, :credit_card, :verified, bankable: mini_market) }

    let!(:sa1) { create(:bank_account, :savings, :verified, bank_name: "Alpha", bankable: mini_market) }
    let!(:sa2) { create(:bank_account, :savings, :verified, bankable: mini_market) }
    let!(:sa3) { create(:bank_account, :savings, bankable: mini_market) }

    let!(:ca1) { create(:bank_account, :checking, :verified, bank_name: "Beta", bankable: mini_market) }
    let!(:ca2) { create(:bank_account, :checking, :verified, bankable: mini_market) }
    let!(:ca3) { create(:bank_account, :checking, bankable: mini_market) }

    let(:other_accounts) {
      [ create(:bank_account, :savings, :verified),
        create(:bank_account, :checking, :verified) ]
    }

    before do
      sa2.soft_delete
      ca2.soft_delete
    end

    it "selects checking and savings accounts that are visible and verified" do
      accts = finder.creditable_bank_accounts(bank_accounts: mini_market.bank_accounts)
      expect(accts).to eq([ sa1, ca1 ])
    end
  end
    
end
