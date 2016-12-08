require 'spec_helper'

describe "stripe plan.created event", vcr: true, webhook: true do
  let!(:start_up) { create(:plan, :start_up) }
  let!(:grow) { create(:plan, :grow) }

  it "creates a plan" do
    expect(find_plans.count).to eq 2
    response = post '/webhooks/stripe', JSON.parse(File.read('spec/features/webhooks/plan.created.json'))

    expect(response.status).to eq 200

    # See the Plan in the database:
    expect(find_plans.count).to eq 3

    expect(find_plans.last.stripe_id).to eq 'KXM2'
  end

  #
  # HELPERS
  #

  def find_plans
    Plan.all
  end

end
