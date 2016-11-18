require 'spec_helper'

describe "stripe plan.created event", vcr: true, webhook: true do
  let!(:start_up) { create(:plan, :start_up) }
  let!(:grow) { create(:plan, :grow) }

  it "creates a plan" do
    expect(find_plans.count).to eq 2
    post '/webhooks/stripe', JSON.parse(File.read('spec/features/webhooks/plan.created.json'))

    # See the Plan in the database:
    expect(find_plans.count).to eq 3
  end

  #
  # HELPERS
  #

  def find_plans
    Plan.all
  end

end
