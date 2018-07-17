require 'spec_helper'

describe "stripe charge.failed event", vcr: true, webhook: true do
  # let(:stripe_customer_id) {'cus_9fi2Qh8obGo7gk'} # matches charge.failed.json
  # let(:stripe_charge_id) {'ch_19MP9b2VpjOYk6TmWPIYC30h'} # matches charge.failed.json
end

#
# HELPERS
#
