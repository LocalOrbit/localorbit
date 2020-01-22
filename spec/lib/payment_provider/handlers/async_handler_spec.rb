require 'spec_helper'

describe PaymentProvider::Handlers::AsyncHandler do
  let(:call) { described_class.new.call(event) }

  before(:all) {
    VCR.turn_off!
    StripeMock.start
  }
  after(:all) {
    StripeMock.stop
    VCR.turn_on!
  }

  describe '#call' do
    context 'livemode outside production env' do
      let(:event) { StripeMock.mock_webhook_event('payout.paid.livemode') }

      it 'raises RuntimeError' do
        expect { call }.to raise_error {|e|
          expect(e).to be_a RuntimeError
          expect(e.message).to eq('Cannot run in Stripe livemode if not in production')
        }
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
      let(:event) { StripeMock.mock_webhook_event('payout.paid', { livemode: false }) }
      let(:delay) { double }

      it 'delegates to configured handler' do
        expect(PaymentProvider::Handlers::PayoutPaid).to receive(:extract_job_params).with(event).and_return('the params')
        expect(PaymentProvider::Handlers::PayoutPaid).to receive(:delay).and_return(delay)
        expect(delay).to receive(:handle).with('the params')
        call
      end
    end
  end
end
