require "spec_helper"

describe Admin::Financials::InvoicesController do
  include_context "the mini market"

  before do
    switch_to_subdomain mini_market.subdomain
    sign_in mary
  end

  describe "#index" do
    it "tracks the viewed-invoices" do
      get :index

      e = EventTracker.previously_captured_events.first
      expect(e).to be
      expect(e).to eq({
        user: mary, 
        event: EventTracker::ViewedInvoices.name, 
        metadata: {}
      })
    end
  end

  describe "#create" do
    it "tracks the fact we batch previewed some invoices" do
      post :create, invoice_list_batch_action: "preview-selected-invoices", order_id: [order1.id,order2.id]

      e = EventTracker.previously_captured_events.first
      expect(e).to be
      expect(e).to eq({
        user: mary, 
        event: EventTracker::PreviewedBatchInvoices.name, 
        metadata: {
          num_invoices: 2
        }
      })
      
    end
  end
end
