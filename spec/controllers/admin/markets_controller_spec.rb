require 'spec_helper'

describe Admin::MarketsController do
  let(:admin)  { create(:user, :admin) }
  let(:market) { create(:market) }

  describe "#index" do
    it_behaves_like "admin only action", lambda { get :index }
  end

  describe "#new" do
    it_behaves_like "admin only action", lambda { get :new }
  end

  describe "#create" do
    context "when not signed in" do
      it_behaves_like "admin only action", lambda {
        post :create
      }
    end

    context "when signed in" do
      before do
        sign_in admin
        allow(controller).to receive(:market_params)
      end

      context "success" do
        it "redirects to admin market page" do
          allow(RegisterMarket).to receive(:perform) { double("Results", success?: true, market: market) }

          post :create
          expect(response).to redirect_to(admin_market_path(market))
        end
      end

      context "failure" do
        it "renders the new page" do
          allow(RegisterMarket).to receive(:perform) { double("Results", success?: false, market: market) }

          post :create
          expect(response).to be_success
          expect(response).to render_template('new')
        end
      end
    end
  end

  describe "#update succeeds" do
    before do
      allow_any_instance_of(Market).to receive(:update_attributes) { true }
      allow(controller).to receive(:market_params)
    end

    it_behaves_like "admin only action", lambda {
      patch :update, id: market.id
    }
  end

  describe "#update fails" do
    before do
      sign_in admin
      allow_any_instance_of(Market).to receive(:update_attributes) { false }
      allow(controller).to receive(:market_params)
    end

    it "renders the new page" do
      patch :update, id: market.id
      expect(response).to be_success
      expect(response).to render_template('edit')
    end
  end
end
