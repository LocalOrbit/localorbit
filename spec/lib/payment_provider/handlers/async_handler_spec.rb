require 'spec_helper'

describe PaymentProvider::Handlers::AsyncHandler do
  let(:call) { described_class.new.call(event) }

  describe '#call' do
    context 'livemode outside production env' do
      let(:event) { double(livemode: true) }

      it 'raises RuntimeError' do
        expect { call }.to raise_error(RuntimeError)
      end
    end

    context 'for event without subscription' do
      let(:event) { double(type: 'not.supported', livemode: false) }

      it 'does nothing' do
        PaymentProvider::Handlers::AsyncHandler::HANDLER_IMPLS.values.each do |handler|
          expect(handler).to_not receive(:extract_job_params)
          expect(handler).to_not receive(:delay)
        end
        call
      end
    end

    context 'for event with subscription' do
      let(:event) { double(type: 'transfer.paid', id: 'evt_1234567', livemode: false) }
      let(:delay) { double }

      it 'delegates to configured handler' do
        expect(PaymentProvider::Handlers::TransferPaid).to receive(:extract_job_params).with(event).and_return('the params')
        expect(PaymentProvider::Handlers::TransferPaid).to receive(:delay).and_return(delay)
        expect(delay).to receive(:handle).with('the params')
        call
      end
    end
  end
end
