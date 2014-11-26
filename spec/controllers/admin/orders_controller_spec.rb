require "spec_helper"

describe Admin::OrdersController do
  include_context "the mini market"

  let(:order) { order1 } # defined in mini market

  before do
    switch_to_subdomain mini_market.subdomain
    sign_in mary
  end

  describe "#show" do
    it "tracks the viewed-order event" do
      get :show, {id: order.id}

      e = EventTracker.previously_captured_events.first
      expect(e).to be
      expect(e).to eq({
        user: mary, 
        event: EventTracker::ViewedOrder.name, 
        metadata: {
          order: { 
            url: admin_order_url(order), 
            value: order.order_number
          }
        }
      })
    end
  end
end
