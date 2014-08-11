require 'spec_helper'

describe ProcessPaymentWithBalanced do
  let(:market)       { create(:market, balanced_customer_uri: "/this-customer") }
  let(:bank_account) { create(:bank_account, :checking, :verified, bankable: market, balanced_uri: "/this-bank-account") }

  context "as credit" do
    let(:payment) { create(:payment, market: market, payer: nil, payee:  market, payment_type: "delivery fee", amount: "14.50", status: "pending", payment_method: "ach", bank_account: bank_account) }
    let(:balanced_credit) { double(Balanced::Credit, uri: "/this-credit") }
    let(:balanced_bank_account) { double(Balanced::BankAccount, credit: balanced_credit) }

    before do
      allow(Balanced::BankAccount).to receive(:find).and_return(balanced_bank_account)
    end

    it "looks up the correct bank account" do
      expect(Balanced::BankAccount).to receive(:find).with("/this-bank-account").and_return(balanced_bank_account)

      ProcessPaymentWithBalanced.perform(payment: payment)
    end

    it "processes the correct credit" do
      expect(balanced_bank_account).to receive(:credit).with(amount: 1450, description: "Local Orbit", appears_on_statement_as: "Local Orbit").and_return(balanced_credit)

      ProcessPaymentWithBalanced.perform(payment: payment)
    end

    it "updates the payment with the credit url" do
      ProcessPaymentWithBalanced.perform(payment: payment)

      payment.reload
      expect(payment.balanced_uri).to eq("/this-credit")
    end

    it "allows you to override the default description" do
      expect(balanced_bank_account).to receive(:credit).with(amount: 1450, description: "Locally Orbiting", appears_on_statement_as: "Local Orbit").and_return(balanced_credit)

      ProcessPaymentWithBalanced.perform(payment: payment, description: "Locally Orbiting")
    end

    it "allows you to override the default appears on statement as" do
      expect(balanced_bank_account).to receive(:credit).with(amount: 1450, description: "Local Orbit", appears_on_statement_as: "Locally Orbiting").and_return(balanced_credit)

      ProcessPaymentWithBalanced.perform(payment: payment, appears_on_statement_as: "Locally Orbiting")
    end
  end

  context "as debit" do
    let(:payment) { create(:payment, market: market, payer:  market, payee: nil, payment_type: "service", amount: "250.00", status: "pending", payment_method: "ach", bank_account: bank_account) }
    let(:balanced_debit) { double(Balanced::Debit, uri: "/this-debit") }
    let(:balanced_customer) { double(Balanced::Customer, debit: balanced_debit) }

    before do
      allow(Balanced::Customer).to receive(:find).and_return(balanced_customer)
    end

    it "looks up the correct balanced customer" do
      expect(Balanced::Customer).to receive(:find).with("/this-customer").and_return(balanced_customer)

      ProcessPaymentWithBalanced.perform(payment: payment)
    end

    it "processes the correct debit" do
      expect(balanced_customer).to receive(:debit).with(amount: 25000, description: "Local Orbit", appears_on_statement_as: "Local Orbit", source_uri: "/this-bank-account").and_return(balanced_debit)

      ProcessPaymentWithBalanced.perform(payment: payment)
    end

    it "updates the payment with the credit url" do
      ProcessPaymentWithBalanced.perform(payment: payment)

      payment.reload
      expect(payment.balanced_uri).to eq("/this-debit")
    end

    it "allows you to override the default description" do
      expect(balanced_customer).to receive(:debit).with(amount: 25000, description: "Locally Orbiting", appears_on_statement_as: "Local Orbit", source_uri: "/this-bank-account").and_return(balanced_debit)

      ProcessPaymentWithBalanced.perform(payment: payment, description: "Locally Orbiting")
    end

    it "allows you to override the default appears on statement as" do
      expect(balanced_customer).to receive(:debit).with(amount: 25000, description: "Local Orbit", appears_on_statement_as: "Locally Orbiting", source_uri: "/this-bank-account").and_return(balanced_debit)

      ProcessPaymentWithBalanced.perform(payment: payment, appears_on_statement_as: "Locally Orbiting")
    end

    it "records a failed transaction when encountering an error" do
      expect(balanced_customer).to receive(:debit).and_raise(StandardError)

      ProcessPaymentWithBalanced.perform(payment: payment)

      payment.reload
      expect(payment.status).to eq("failed")
      expect(payment.note).to be_nil
    end

    it "records a note about the failure if provided" do
      expect(balanced_customer).to receive(:debit).and_raise(Balanced::PaymentRequired.new({status: 402, method: "POST", body: {category_code: "card-declined"}}))

      ProcessPaymentWithBalanced.perform(payment: payment)

      payment.reload
      expect(payment.status).to eq("failed")
      expect(payment.note).to eq("Error: card-declined")
    end

    it "adds to an existing note about the failure if provided" do
      payment.note = "A great note"
      payment.save!

      expect(balanced_customer).to receive(:debit).and_raise(Balanced::PaymentRequired.new({status: 402, method: "POST", body: {category_code: "card-declined"}}))

      ProcessPaymentWithBalanced.perform(payment: payment)

      payment.reload
      expect(payment.status).to eq("failed")
      expect(payment.note).to eq("A great note Error: card-declined")
    end
  end

  context "as refund" do
    let(:parent_payment)  { create(:payment, market: market, payer:  market, payee: nil, payment_type: "service", amount: "250.00", status: "pending", payment_method: "ach", bank_account: bank_account, balanced_uri: "/this-debit") }
    let(:payment)         { create(:payment, market: market, payer:  market, payee: nil, payment_type: "service refund", amount: "-250.00", status: "pending", payment_method: "ach", bank_account: bank_account, parent: parent_payment) }
    let(:balanced_refund) { double(Balanced::Refund, uri: "/this-refund") }
    let(:balanced_debit)  { double(Balanced::Debit, uri: "/this-debit", refund: balanced_refund) }


    before do
      allow(Balanced::Transaction).to receive(:find).and_return(balanced_debit)
    end

    it "looks up the correct balanced debit" do
      expect(Balanced::Transaction).to receive(:find).with("/this-debit").and_return(balanced_debit)

      ProcessPaymentWithBalanced.perform(payment: payment)
    end

    it "processes the correct refund" do
      expect(balanced_debit).to receive(:refund).with(amount: 25000).and_return(balanced_refund)

      ProcessPaymentWithBalanced.perform(payment: payment)
    end
    
    it "updates the payment with the refund url" do
      ProcessPaymentWithBalanced.perform(payment: payment)

      payment.reload
      expect(payment.balanced_uri).to eq("/this-refund")
    end
  end
end
