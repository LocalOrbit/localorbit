require 'spec_helper'

describe ProductsController do
  let(:org1) { create(:organization) }
  let(:org2) { create(:organization) }
  let(:product1) { create(:product, :sellable, organization: org2) }
  let(:product2) { create(:product, :sellable, organization: org2) }
  let(:market) { create(:market, organizations: [org1, org2]) }
  let(:user) { create(:user, organizations: [org1]) }
  let!(:location) { create(:location, organization: org1) }

  describe "/index" do
    context "on a market subdomain" do
      before do
        switch_to_subdomain market.subdomain
      end

      it "redirects to new address page if you don't have any locations" do
        location.soft_delete
        sign_in user
        get :index

        expect(response).to redirect_to(new_admin_organization_location_path(org1))
      end
    end

    context "on the main domain" do
      let(:admin) { create(:user, :admin) }
      before do
        switch_to_main_domain
        sign_in admin
      end

      it "requires a market" do
        get :index
        expect(response).to be_success
        expect(response).to render_template("select_market")
      end
    end
  end
end
