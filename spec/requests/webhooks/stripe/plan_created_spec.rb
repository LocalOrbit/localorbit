require 'spec_helper'

describe 'plan.created webhook', type: :request, vcr: true do
  it 'creates a plan' do
    expect { post_webhook('plan.created') }.to change { Plan.count }.by(1)
    expect(response).to have_http_status(:ok)
    expect(Plan.last.stripe_id).to eq 'KXM2'
  end
end
