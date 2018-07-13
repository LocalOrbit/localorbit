require 'spec_helper'

describe PaymentMailer, type: :mailer do

  describe '.payment_made' do
    let(:recipients) { build_list(:user, 2).map(&:email) }
    let(:payment) { build_stubbed(:payment) }
    let(:mail) { PaymentMailer.payment_made(recipients, payment) }

    it 'has the correct subject' do
      expect(mail.subject).to match('You Have Made a Payment')
    end

    it 'renders the correct template' do
      expect(mail.body.encoded).to match('You just paid')
    end
  end

  describe '.payment_received' do
    let(:recipients) { build_list(:user, 2).map(&:email) }
    let(:payment) { build_stubbed(:payment) }
    let(:mail) { PaymentMailer.payment_received(recipients, payment) }

    it 'has the correct subject' do
      expect(mail.subject).to match('You Have Received a Payment')
    end

    it 'renders the correct template' do
      expect(mail.body.encoded).to match('A payment was sent')
    end
  end

end
