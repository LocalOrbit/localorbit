describe Financials::SellerPayments::Processor do
  subject(:processor) { described_class }


  describe ".pay_and_notify_seller" do
    let(:payment_converter) { Financials::SellerPayments::PaymentConverter }
    let(:payment_builder) { Financials::PaymentBuilder }
    let(:payment_executor) { Financials::PaymentExecutor }
    let(:payment_notifier) { Financials::PaymentNotifier }

    let(:seller_section) { double "Seller section" }
    let(:bank_account_id) { double "Bank account id" }
    let(:payment_info) { double "Payment info" }
    let(:payment) { double "Payment", status: "pending" }
    let(:seller_section) { double "Seller section" }

    it "builds and executes a Payment then notifies sellers" do
      expect(payment_converter).to receive(:seller_section_to_payment_info).
        with(seller_section: seller_section, 
             bank_account_id: bank_account_id).
        and_return(payment_info)

      expect(payment_builder).to receive(:payment_to_seller).
        with(payment_info: payment_info).
        and_return(payment)

      expect(payment_executor).to receive(:execute_credit).
        with(payment: payment,
             description: "Payment to Seller on 'Automate'").
        and_return(payment)

      expect(payment_notifier).to receive(:seller_payment_received).
        with(payment: payment)

      ret = processor.pay_and_notify_seller(seller_section: seller_section, bank_account_id: bank_account_id)
      expect(ret).to eq payment
    end

    context "when payment executor fails" do
      let(:payment) { double "Failed Payment", status: "failed" }

      it "doesn't send notification to sellers" do
        expect(payment_converter).to receive(:seller_section_to_payment_info).
          with(seller_section: seller_section, 
               bank_account_id: bank_account_id).
          and_return(payment_info)

        expect(payment_builder).to receive(:payment_to_seller).
          with(payment_info: payment_info).
          and_return(payment)

        expect(payment_executor).to receive(:execute_credit).
          with(payment: payment,
               description: "Payment to Seller on 'Automate'").
          and_return(payment)

        expect(payment_notifier).not_to receive(:seller_payment_received)

        ret = processor.pay_and_notify_seller(seller_section: seller_section, bank_account_id: bank_account_id)
        expect(ret).to eq payment
      end
    end
  end
end
