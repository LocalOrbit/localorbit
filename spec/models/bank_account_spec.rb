require "spec_helper"

describe BankAccount do
  context "model" do
    let(:bank_account) { create(:bank_account, bank_name: "Visa", last_four: "4280", expiration_month: 8, expiration_year: 2032) }

    it "formats card display_name correctly" do
      expect(bank_account.display_name).to eq("Visa ending in 4280 (exp. 8/2032)")
    end
  end

  context "validations" do
    let!(:organization) { create(:organization) }

    context "for checking accounts" do
      let(:account_params) {{
        account_type: "checking",
        last_four: "1234",
        name: "John User",
        bankable: organization,
        bank_name: "House of Dollars"
      }}
      let!(:bank_account) { create(:bank_account, account_params) }

      it "does not allow duplicate account" do
        subject = BankAccount.new(account_params)
        expect(subject).to have(1).errors_on(:bankable_id)
        field,msg = subject.errors.first
        expect(field).to eq(:bankable_id)
        expect(msg).to match(/already exists/)
      end

      it "does not allow account with different expiration month/year" do
        subject = BankAccount.new(account_params.merge(expiration_month: "9", expiration_year: "2044"))
        expect(subject).to have(1).errors_on(:bankable_id)
        field,msg = subject.errors.first
        expect(field).to eq(:bankable_id)
        expect(msg).to match(/already exists/)
      end

      it "allows checking account with different last_four" do
        subject = BankAccount.new(account_params.merge(last_four: "6789"))
        expect(subject).to be_valid
      end
    end

    context "for credit card accounts" do
      let(:account_params) {{
        account_type: "card",
        last_four: "1234",
        expiration_month: "08",
        expiration_year: "2032",
        name: "John User",
        bankable: organization,
        bank_name: "Visa"
      }}
      let!(:bank_account) { create(:bank_account, account_params) }

      it "does not allow identical account" do
        subject = BankAccount.new(account_params.dup)
        expect(subject).to have(1).errors_on(:bankable_id)
        field,msg = subject.errors.first
        expect(field).to eq(:bankable_id)
        expect(msg).to match(/already exists/)
      end

      it "allows identical account associated with different organization" do
        new_org = create(:organization, :buyer)
        subject = BankAccount.new(account_params.merge(bankable: new_org))
        expect(subject).to be_valid
      end

      it "allows account with different name" do
        subject = BankAccount.new(account_params.merge(name: "New Name"))
        expect(subject).to be_valid
      end

      it "allows account with different last four" do
        subject = BankAccount.new(account_params.merge(last_four: "6789"))
        expect(subject).to be_valid
      end

      it "allows account with different expiration month" do
        subject = BankAccount.new(account_params.merge(expiration_month: "04"))
        expect(subject).to be_valid
      end

      it "allows account with different expiration month" do
        subject = BankAccount.new(account_params.merge(expiration_year: "2026"))
        expect(subject).to be_valid
      end
    end

    it "does not check soft deleted bank accounts when checking for duplications" do
      create(:bank_account, account_type: "visa", last_four: "1234", bankable: organization, deleted_at: Time.current)

      subject = BankAccount.new(bankable: organization, account_type: "visa", last_four: "1234")
      expect(subject).to be_valid
    end

    it "calling valid? does not return a false negative" do
      subject = create(:bank_account, account_type: "visa", last_four: "1234", bankable: organization, deleted_at: Time.current)
      expect(subject.valid?).to eql(true)
    end
  end

  context "verification_failed?" do
    it "is false if the bank account is verified" do
      subject.verified = true

      expect(subject).not_to be_verification_failed
    end

    it "is true if we can't find a bank account verification" do
      expect(subject).to receive(:balanced_verification).and_return(nil)

      expect(subject).to be_verification_failed
    end
  end

  describe "soft_delete" do
    include_context "soft delete-able models"
    it_behaves_like "a soft deleted model"
  end

  describe "#primary_payment_provider" do
    let(:provider) { "the payment provider" }
    let!(:market) { create(:market, payment_provider: provider) }
    let!(:organization) { create(:organization, :buyer, markets:[market]) }
    let!(:bank_account) { create(:bank_account) }

    context "when bankable is a market" do
      before { bank_account.update(bankable: market) }

      it "returns the market's payment provider" do
        expect(bank_account.primary_payment_provider).to eq provider
      end
    end

    context "when bankable is an organization" do
      before { bank_account.update(bankable: organization) }

      it "returns the organization's first market's payment provider" do
        expect(bank_account.primary_payment_provider).to eq provider
      end
    end

    context "when bankable mysteriously doesn't respond to #primary_payment_provider" do
      before do
        # Total fake-out; our real objects can't currently get us into a situation where
        # a BankAccount has bankable that's not an Organization or a Market
        allow(bank_account).to receive(:bankable).and_return "oops"
      end

      it "raises an error" do
        expect(lambda { bank_account.primary_payment_provider }).to raise_error(/oops.*primary_payment_provider/)
      end
    end
  end

  describe "deposit_accounts scope" do
    let!(:checking_accounts) { create_list(:bank_account, 3, :checking) }
    let!(:other_accounts) { create_list(:bank_account, 2, :credit_card) }
    let(:all_accounts) { checking_accounts.concat(other_accounts) }

    before do
      checking_accounts[0].update(account_role: 'deposit')
      checking_accounts[2].update(account_role: 'deposit')
    end

    it "returns only accounts with accoun_role=deposit" do
      expect(BankAccount.all.to_a.to_set).to eq(all_accounts.to_set)
      expect(BankAccount.all.deposit_accounts.to_a.to_set).to eq([checking_accounts[0], checking_accounts[2]].to_set)
    end
  end

end
