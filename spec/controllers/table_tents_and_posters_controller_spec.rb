require "spec_helper"

describe TableTentsAndPostersController do
  let(:admin) { create(:user, :admin) }
  before do
    sign_in admin
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
end