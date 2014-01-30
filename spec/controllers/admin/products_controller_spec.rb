require 'spec_helper'

describe Admin::ProductsController do
  describe "/show" do
    let(:user) { create(:user) }
    let(:product1) { create(:product) }
    let(:product2) { create(:product) }

    before do
      user.organizations << product1.organization
      sign_in(user)
    end

    it "does not show a product from another organization" do
      get :show, {id: product2.id}

      expect(response).to be_not_found
    end
  end

  describe "/create" do
    let(:user) { create(:user) }
    let(:org1) { create(:organization) }
    let(:org2) { create(:organization) }

    before do
      org1.users << user
      sign_in(user)
    end

    it 'should not let a user create a product for an organization they do not belong to' do
      post :create, {product: {organization_id: org2, name: "Apple", category_id: 1}}

      expect(response).to render_template("admin/products/new")
      expect(assigns(:product)).to have(1).errors_on(:organization_id)
    end
  end
end
