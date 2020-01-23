require "spec_helper"

describe Admin::Financials::InvoicesController do
  include_context "the mini market"

  before do
    switch_to_subdomain mini_market.subdomain
    sign_in mary
  end

  describe "#create" do
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
