require 'spec_helper'

describe PaymentProvider::Handlers::AsyncHandler do

  describe '#call' do
    it 'does nothing if no handler is found' do
      event = double(type: 'not.supported')
      PaymentProvider::Handlers::AsyncHandler::HANDLER_IMPLS.values.each do |handler|
        expect(handler).to_not receive(:extract_job_params)
        expect(handler).to_not receive(:delay)
      end
      subject.call(event)
    end

    it 'delegates to configured handler for event type' do
      event = double(type: 'transfer.paid')
      delay = double()
      expect(PaymentProvider::Handlers::TransferPaid).to receive(:extract_job_params).with(event).and_return('the params')
      expect(PaymentProvider::Handlers::TransferPaid).to receive(:delay).and_return(delay)
      expect(delay).to receive(:handle).with('the params')
      subject.call(event)
    end
  end
end
