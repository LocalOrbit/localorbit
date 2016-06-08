require "spec_helper"

describe Admin::PricesController do
  let!(:seller) { create(:organization, :seller)}
  let!(:product) { create(:product, organization: seller) }
  let!(:user)  { create(:user, :supplier, organizations: [seller]) }
  let!(:user2) { create(:user, :supplier) }

  describe "/index" do
    context "a user who is not logged in" do
      it "redirects to the login screen" do
        get :index, product_id: product.id
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "a user that does not have access to a product" do
      it "responds with a 404" do
        sign_in(user2)

        get :index, product_id: product.id
        expect(response).to be_not_found
      end
    end
  end

  describe "/create" do
    context "a user who is not logged in" do
      it "redirects to the login screen" do
        post :create, product_id: product.id
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "a user that does not have access to a product" do
      it "responds with a 404" do
        sign_in(user2)

        post :create, product_id: product.id
        expect(response).to be_not_found
      end
    end
  end
end
