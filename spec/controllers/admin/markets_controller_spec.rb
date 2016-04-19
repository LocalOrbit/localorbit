require "spec_helper"

describe Admin::MarketsController do
  let(:admin)  { create(:user, :admin) }
  let(:market) { create(:market, stripe_standalone: false) }
  let(:market2) { create(:market, stripe_standalone: true) }

  describe "#index" do
    it_behaves_like "admin only action", lambda { get :index }
  end

  describe "#new" do
    it_behaves_like "admin only action", lambda { get :new }
  end

  describe "#create" do
    context "when not signed in" do
      it_behaves_like "admin only action", lambda {

        allow(RegisterStripeStandaloneMarket).to receive(:perform) { double("Results", success?: true, market: market) }
        post :create, market: {name: "Major Market", subdomain: "major-market", contact_name: "Johnny", contact_email: "johnny@example.com"}
      }
    end

    context "when signed in" do
      before do
        sign_in admin
        allow(controller).to receive(:market_params)
      end

      context "success - standalone" do
        it "redirects to admin market page" do
          allow(RegisterStripeStandaloneMarket).to receive(:perform) { double("Results", success?: true, market: market2) }

          post :create
          expect(response).to redirect_to(admin_market_path(market2))
        end
      end

      context "failure - standalone" do
        it "renders the new page" do
          allow(RegisterStripeStandaloneMarket).to receive(:perform) { double("Results", success?: false, market: market2) }

          post :create
          expect(response).to be_success
          expect(response).to render_template("new")
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
      expect(response).to render_template("show")
    end
  end
end
