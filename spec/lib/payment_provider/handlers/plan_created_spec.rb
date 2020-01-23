require 'spec_helper'

describe PaymentProvider::Handlers::PlanHandler do
  subject { described_class }

  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  describe '.handle' do
    let!(:user) { create(:user) }
    let!(:market) { create(:market, stripe_account_id: 'account id', managers: [user]) }
    let!(:market2) { create(:market) }

    it 'adds a plan' do
      event = StripeMock.mock_webhook_event('plan.created')

      expect {
        subject.handle({ event: event, event_type: 'plan_created' })
      }.to change { Plan.count }.by(1)

      expect(Plan.last.stripe_id).to eq 'KXM2'
    end
  end
end
