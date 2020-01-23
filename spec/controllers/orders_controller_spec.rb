require "spec_helper"

describe OrdersController do
  include_context "the mini market"

  let(:order) { order1 } # defined in mini market

  before do
    switch_to_subdomain mini_market.subdomain
    sign_in mary
  end
end
