require 'spec_helper'

describe "stripe market transfer.paid event", vcr: true do
  it "creates a payment and emails the market's managers" do
    post '/webhooks/stripe', JSON.parse(File.read('spec/features/webhooks/transfer.paid.json'))
    raise "FINISH HIM"
    # TODO: verify market payment created
    # TODO: verify `current_email` sent to markets
  end
end
