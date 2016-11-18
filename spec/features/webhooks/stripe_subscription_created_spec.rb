require 'spec_helper'

describe "stripe customer.subscription.created event", vcr: true, webhook: true do
  xit "finds any existing subscription object" do end

  xit "creates a new subscription object" do
    # post '/webhooks/stripe', JSON.parse(File.read('spec/features/webhooks/plan.created.json'))
  end

  #
  # HELPERS
  #

  # KXM An example helper...
  # def find_plans
  #   Plan.all
  # end

end
