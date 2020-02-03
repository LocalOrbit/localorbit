require 'spec_helper'

RSpec.describe 'Stripe plan events', type: :request do
  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }
  before(:each) { bypass_event_signature payload }

  describe 'plan.created' do
    let(:payload) { File.read('spec/fixtures/webhooks/stripe/plan.created.json') }

    it 'creates a plan' do
      expect(Plan.count).to eq 0

      post '/webhooks/stripe', body: payload

      expect(response).to have_http_status(:ok)
      expect(Plan.count).to eq 1
      expect(Plan.last.stripe_id).to eq 'KXM2'
    end
  end

end
