describe Financials::PaymentExecutor do
  subject(:executor) { described_class }

  let(:balanced_api) { Balanced::BankAccount }
  let(:balanced_account) { double("Balanced Account") }
  let(:credit) { double("Credit", uri: "the credit uri") }

  let(:bank_account) { double("Bank Account", balanced_uri: "the balanced uri") }
  let(:market) { double("Market", on_statement_as: 'market on statement') }
  let(:payment) { double("Payment", 
                         bank_account: bank_account, 
                         market: market, 
                         amount: "42.42".to_d) }

  let(:description) { "some descript" }

  before do
    @saved_state = executor.capture_payments
    executor.capture_payments = false # need to run the Balanced code... we'll mock out at a finer-grained level...
    executor.previously_captured_payments.clear
  end

  after do
    executor.capture_payments = @saved_state
    executor.previously_captured_payments.clear
  end

  describe ".execute_credit" do
    context "with payment and description" do
      it "uses the Balanced API to credit the Payment's targeted bank account" do
        expect_find_balanced_bank_account
        expect_credit
        ret = executor.execute_credit(payment: payment, description: description)
        expect(ret).to eq payment
      end
    end

    context "leaving optional description blank" do
      let(:description) { nil }
      it "provides a nil description" do
        expect_find_balanced_bank_account
        expect_credit
        executor.execute_credit(payment: payment)
      end
    end

    context "payment missing bank_account" do
      let(:bank_account) { nil }

      it "handles the error" do
        expect(executor).to receive(:handle_payment_error).with(payment, "No BankAccount associated with this Payment") 
        ret = executor.execute_credit(payment: payment)
        expect(ret).to eq payment
      end
    end

    context "payment bank_account missing balanced_uri" do
      let(:bank_account) { double("Another Bank Account", balanced_uri: nil) }

      it "handles the error" do
        expect(executor).to receive(:handle_payment_error).with(payment, "BankAccount not linked to a Balanced account: balanced_uri not set") 
        ret = executor.execute_credit(payment: payment)
        expect(ret).to eq payment
      end
    end

    context "when Balanced call raises exception" do
      it "captures and handles the error" do
        expect_find_balanced_bank_account
        expect_and_fail_credit
        expect(executor).to receive(:handle_payment_error).with(payment, "FOOMP", nil) 
        ret = executor.execute_credit(payment: payment, description: description)
        expect(ret).to eq payment
      end
    end

    context "when Balanced call raises exception with a category_code" do
      it "captures and handles the error" do
        expect_find_balanced_bank_account
        expect_and_fail_credit(category_code: "hey-there")
        expect(executor).to receive(:handle_payment_error).with(payment, "FOOMP", "hey-there") 
        ret = executor.execute_credit(payment: payment, description: description)
        expect(ret).to eq payment
      end
    end

    context "when capture_payments is activated" do
      it "stuffs the args into a bucket" do
        begin
          executor.capture_payments = true
          executor.execute_credit(payment: "the payment", description: "the desc")
          expect(executor.previously_captured_payments).to eq([{payment:"the payment", description:"the desc"}])
        ensure
          executor.previously_captured_payments.clear
          executor.capture_payments = @saved_state
        end
      end
    end
  end

  describe ".handle_payment_error" do
    let(:payment) { create(:payment, status: "pending", payee: create(:organization,:seller), note: nil) }

    it "sets Payment status to fail and records error message in the note field." do
      expect(payment.status).to eq "pending"

      executor.handle_payment_error(payment, "oops")

      expect(payment.status).to eq "failed"
      expect(payment.note).to eq "ERROR: oops"
    end

    it "includes the category-code if provided" do
      executor.handle_payment_error(payment, "oops", "cat-code")
      expect(payment.note).to eq "ERROR: oops - Error Code: cat-code"
    end

    it "preserves the existing payment note along with the error message" do
      payment.note = "all paid up!"
      executor.handle_payment_error(payment, "oops", "cat-code")
      expect(payment.note).to eq "all paid up! - ERROR: oops - Error Code: cat-code"
    end
  end

  #
  # HELPERS
  #

  def expect_find_balanced_bank_account
    expect(balanced_api).to receive(:find).
      with(bank_account.balanced_uri).
      and_return(balanced_account)
  end

  def expect_credit
    expect(balanced_account).to receive(:credit).
      with(amount: 4242,
           appears_on_statement_as: market.on_statement_as,
           description: description).
      and_return(credit)
    expect(payment).to receive(:update_column).with(:balanced_uri, credit.uri).and_return(payment)
  end

  class ErrorWithCategory < StandardError
    attr_accessor :category_code
  end

  def expect_and_fail_credit(category_code:nil)
    err = nil
    if category_code
      err = ErrorWithCategory.new("FOOMP")
      err.category_code = category_code
    else
      err = StandardError.new("FOOMP")
    end

    expect(balanced_account).to receive(:credit).
      with(amount: 4242,
           appears_on_statement_as: market.on_statement_as,
           description: description).
      and_raise(err)
  end
end
