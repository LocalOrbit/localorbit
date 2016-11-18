require 'spec_helper'

describe "stripe invoice.payment_succeeded event", vcr: true, webhook: true do

  xit "finds the related organization" do end

  xit "confirmed as unique" do end

  xit "disregards invoices that aren't for subscriptions" do end

  it "creates a new payment object" do
    post '/webhooks/stripe', JSON.parse(File.read('spec/features/webhooks/invoice.payment_succeeded.json'))
  end

  #
  # HELPERS
  #

  # KXM An example helper...
  # def find_plans
  #   Plan.all
  # end

end
