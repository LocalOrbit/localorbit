require "spec_helper"

describe BankAccount do
  context "validations" do
    let!(:organization) { create(:organization) }

    it "does not allow duplication accounts" do
      atts = {
        account_type: "visa",
        last_four: "1234",
        bankable: organization,
        bank_name: "House of Dollars"
      }
      create(:bank_account, atts.dup)

      subject = BankAccount.new(atts.dup)
      expect(subject).to have(1).errors_on(:bankable_id)
      field,msg = subject.errors.first
      expect(field).to eq(:bankable_id)
      expect(msg).to match(/already exists/)

      subject = BankAccount.new(bankable: organization, account_type: "visa", last_four: "1235")
      expect(subject).to be_valid
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

    it "is true if the balanced verification has failed" do
      expect(subject).to receive(:balanced_verification).twice.and_return(double(Balanced::Verification, state: "failed"))

      expect(subject).to be_verification_failed
    end

    it "is false if the balanced verification is pending" do
      expect(subject).to receive(:balanced_verification).twice.and_return(double(Balanced::Verification, state: "pending"))

      expect(subject).not_to be_verification_failed
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

end
