require "spec_helper"

describe TableTentsAndPostersController do
  let(:buyer) { create(:user, :buyer) }
  before do
    sign_in buyer
  end

  describe "#index" do
    it "sets the title and poster type" do
      get :index, order_id: 1, type: "poster"
      expect(assigns(:title)).to eq 'Posters (8.5" x 11")'
      expect(assigns(:printables)).to eq 'posters'
      get :index, order_id: 1
      expect(assigns(:title)).to eq 'Table Tents (4" x 6")'
      expect(assigns(:printables)).to eq 'table tents'
    end
  end

  describe "#create", :wip=>true do
    let (:order) {create(:order, organization: buyer.organizations.first)}

    it "generates a pdf" do
      expect(GenerateTableTentsOrPosters).to receive(:perform).with(order: order, type: "poster", include_product_names: false)
      post :create, order_id: order.id, type: "poster", include_product_names: false
      binding.pry
    end
  end
end