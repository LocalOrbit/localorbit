require "spec_helper"

describe Admin::OrdersController do
  include_context "the mini market"

  let(:order) { order1 } # defined in mini market

  before do
    switch_to_subdomain mini_market.subdomain
    sign_in mary
  end

  describe '#index' do
    let(:upload_queue) { 'true' }

    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('USE_UPLOAD_QUEUE').and_return(upload_queue)

      params = {
        format: format,
        q: {
          placed_at_date_gteq: (order1.created_at - 1).strftime('%F'),
          placed_at_date_lteq: (order1.created_at + 1).strftime('%F')
        }
      }
      get :index, params
    end

    context 'HTML view' do
      let(:format) { 'html' }

      before do
        params = {
          q: {
            placed_at_date_gteq: (order1.created_at - 1).strftime('%F'),
            placed_at_date_lteq: (order1.created_at + 1).strftime('%F')
          }
        }
        get :index, params
      end

      it 'lists orders' do
        expect(assigns(:orders).count).to eq(3)
      end
    end

    context 'CSV export' do
      let(:format) { 'csv' }

      context 'with USE_UPLOAD_QUEUE = true' do
        it 'redirects to orders index' do
          expect(response).to redirect_to '/admin/orders'
        end
      end

      context 'with USE_UPLOAD_QUEUE = false' do
        let(:upload_queue) { 'false' }

        it 'returns successfully' do
          expect(response).to be_success
        end

        it 'has the correct number of order items' do
          expect(assigns(:order_items).count).to eq(3)
        end

        it 'response type is CSV' do
          expect(response.headers['Content-Type']).to eq 'text/csv; charset=utf-8'
        end
      end
    end
  end
end
