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

  describe "#create succeeds" do
    before do
      allow_any_instance_of(Market).to receive(:save) { true }
      allow(controller).to receive(:market_params)
    end

    it_behaves_like "admin only action", lambda {
      post :create
    }
  end

  describe "#create fails" do
    before do
      sign_in admin
      allow_any_instance_of(Market).to receive(:save) { false }
      allow(controller).to receive(:market_params)
    end

    it "renders the new page" do
      post :create
      expect(response).to be_success
      expect(response).to render_template('new')
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
