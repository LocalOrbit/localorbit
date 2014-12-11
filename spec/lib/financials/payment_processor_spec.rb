
describe Financials::PaymentProcessor do
  subject(:processor) { described_class }

  describe ".pay_and_notify" do
    let(:payment_executor) { Financials::PaymentExecutor }
    let(:payment_notifier) { Financials::PaymentNotifier }
    let(:payment_info_converter) { Financials::PaymentInfoConverter }

    let(:converter_inputs) { double "Approriate inputs for the info converter" }

    let(:payment_config) { Financials::PaymentMetadata::Configs[:delivery_fees_to_market] || raise("Uh, we really need a payment config for this test")}
    let(:payment_info) { 
      {
        payee:        Organization.new,
        bank_account: BankAccount.new,
        amount:       50.to_d,
        market:       Market.new,
        orders:       [Order.new]
      } 
    }

    let(:payment_attributes) {
      payment_config[:payment_base_attrs].merge(payment_info)
    }

    let(:payment) { Payment.new(status:"pending") }

    it "executes a Payment then notifies sellers" do
      expect(payment_info_converter).to receive(payment_config[:payment_info_converter]).
        with(converter_inputs).
        and_return(payment_info)

      expect(payment_executor).to receive(:execute_credit).
        with(payment_attributes: payment_attributes,
             description: payment_config[:description]).
        and_return(payment)

      expect(payment_notifier).to receive(payment_config[:payment_notifier]).
        with(payment: payment)

      ret = processor.pay_and_notify(
        payment_config: payment_config,
        inputs: converter_inputs
      )

      expect_valid_schema Financials::PaymentProcessor::Result, ret
      expect(ret).to eq({ status: :ok, payment: payment })
    end

    context "when payment amount is 0" do
      before do
        payment_info[:amount] = 0.to_d
      end

      it "skips the payment" do
        expect(payment_info_converter).to receive(payment_config[:payment_info_converter]).
          with(converter_inputs).
          and_return(payment_info)

        expect(payment_executor).not_to receive(:execute_credit)

        ret = processor.pay_and_notify(
          payment_config: payment_config,
          inputs: converter_inputs
        )

        expect_valid_schema Financials::PaymentProcessor::Result, ret
        expect(ret).to eq({ 
          status: :payment_skipped, 
          payment_info: payment_info,
          message: "Payment skipped due to 0 amount"
        })
      end
    end

    context "when payment executor fails" do
      let(:payment) { Payment.new(status:"failed") }

      it "doesn't send notification to sellers, and returns failure information" do
        expect(payment_info_converter).to receive(payment_config[:payment_info_converter]).
          with(converter_inputs).
          and_return(payment_info)

        expect(payment_executor).to receive(:execute_credit).
          with(payment_attributes: payment_attributes,
               description: payment_config[:description]).
          and_return(payment)

        expect(payment_notifier).not_to receive(payment_config[:payment_notifier])

        ret = processor.pay_and_notify(
          payment_config: payment_config,
          inputs: converter_inputs
        )

        expect_valid_schema Financials::PaymentProcessor::Result, ret
        expect(ret).to eq({ 
          status: :payment_failed, 
          payment: payment,
          message: "Payment failed"
        })
      end
    end
  end
end
