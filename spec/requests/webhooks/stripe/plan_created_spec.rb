require 'spec_helper'

describe 'plan.created webhook', type: :request, vcr: true do
  it 'creates a plan' do
    expect(Plan.count).to eq 0
    post '/webhooks/stripe', JSON.parse(File.read('spec/fixtures/webhooks/stripe_requests/plan.created.json'))
    expect(response).to have_http_status(:ok)
    expect(Plan.count).to eq 1
    expect(Plan.last.stripe_id).to eq 'KXM2'
  end
end
