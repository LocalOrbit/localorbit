require "spec_helper"

describe Admin::Financials::InvoicesController do

  include_context "the mini market"
  include_context "intercom enabled"

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
    context 'previews two invoices' do
      before do
        post :create, invoice_list_batch_action: "preview-selected-invoices", order_id: [order1.id,order2.id]
      end

      it "tracks the fact we batch previewed some invoices" do
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

    context 'sends two invoices' do
      before do
        post :create, invoice_list_batch_action: "send-selected-invoices", order_id: [order1.id,order2.id]
      end

      it 'redirects back to list' do
        # expect(response).to be_success
        expect(request).to redirect_to("/admin/financials/invoices")
      end

      it 'shows right message' do
        expect(flash[:notice]).to eq('Successfully sent 2 invoices. Sent invoices can be downloaded from the Enter Receipts page.')
      end
    end

    context 'marks two invoices as invoiced' do
      before do
        post :create, invoice_list_batch_action: "mark-selected-invoiced", order_id: [order1.id,order2.id]
      end

      it 'redirects back to list' do
        expect(request).to redirect_to("/admin/financials/invoices")
      end

      it 'shows right message' do
        expect(flash[:notice]).to eq('Successfully marked 2 orders invoiced. Invoices can be downloaded from the Enter Receipts page.')
      end
    end
  end
end
