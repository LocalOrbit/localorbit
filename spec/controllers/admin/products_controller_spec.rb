require "spec_helper"

describe Admin::ProductsController do
  let(:supplier) { create(:organization, :seller)}
  let(:product1) { create(:product, organization: supplier) }
  let(:product2) { create(:product) }
  let(:market) { create(:market, organizations: [supplier]) }
  let(:org1) { create(:organization, :seller) }
  let(:org2) { create(:organization, :seller) }
  let(:user) { create(:user, :supplier, organizations:[supplier]) }

  before do
    switch_to_subdomain market.subdomain
  end

  describe "/index" do
    it "redirects to login if the user is not logged in" do
      get :index

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "/show" do
    before do
      sign_in(user)
    end

    it "does not show a product from another organization" do
      get :show, id: product2.id

      expect(response).to be_not_found
    end
  end

  describe "/create" do
    before do
      sign_in(user)
    end

    it "should not let a user create a product for an organization they do not belong to" do
      post :create, product: {organization_id: org2, name: "Apple", category_id: 1}

      expect(response).to render_template("admin/products/new")
      expect(assigns(:product).organization).to eq(product1.organization)
    end
  end

  describe "/update" do
    let(:product) { create(:product) }

    before do
      org1.users << user
      sign_in(user)
    end

    it "should not let a user update a product that does not belong to their organization" do
      put :update, id: product.id, product: {organization_id: org1.id, name: "Apple", category_id: 1}

      expect(response).to be_not_found
    end
  end

  describe "/new" do
    it "redirects to the add organization page when no selling organizations exist" do
      Organization.destroy_all

      admin = create(:user, :admin)
      sign_in admin

      get :new

      expect(response).to redirect_to(new_admin_organization_path)
      expect(flash[:alert]).to eq("You must add an organization that can sell before adding any products")
    end
  end

  describe "destroy" do
    let(:seller)                    { create(:organization, :seller)}
    let(:product)                   { create(:product, organization: seller) }
    let(:admin)                     { create(:user, :admin) }
    let(:non_member)                { create(:user, :supplier) }
    let(:market_manager_non_member) { create(:user, :market_manager) }
    let(:organization_member)       { create(:user, :supplier, organizations:[seller]) }
    let(:market_manager_member)     { create(:user, :market_manager, organizations: [seller]) }
    let(:market)                    { create(:market, organizations:[seller])}

    it_behaves_like "an action restricted to admin, market manager, member", lambda { delete :destroy, id: product.id }
  end
end
