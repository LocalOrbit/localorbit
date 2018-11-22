require 'spec_helper'

describe Payment do
  context 'validations' do
    before do
      subject.payee_id = 1
    end

    it 'requires a payee or payer to be specified' do
      subject.payee_id = nil
      expect(subject).to have(1).errors_on(:base)
    end

    it 'requires amount to be a number' do
      subject.amount = 'NaN'
      expect(subject).to have(1).errors_on(:amount)
    end
  end

  describe '#fail!' do
    let(:payment) { create(:payment, payee: create(:organization)) } # FIXME: factory should make payee

    it 'changes the status to failed' do
      expect(payment.status).to eq 'paid'
      payment.fail!
      expect(payment.status).to eq 'failed'
      expect(payment.persisted?).to be
    end
  end
end
