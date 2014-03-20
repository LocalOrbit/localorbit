require 'spec_helper'

describe ProductsController do
  let(:org1) { create(:organization) }
  let(:org2) { create(:organization) }
  let(:product1) { create(:product, :sellable, organization: org2) }
  let(:product2) { create(:product, :sellable, organization: org2) }
  let(:market) { create(:market, organizations: [org1, org2]) }
  let(:user) { create(:user, organizations: [org1]) }


  before do
    switch_to_subdomain market.subdomain
  end

  describe "/index" do
    it "redirects to new address page if you don't have any locations" do
      create(:location, organization: org1, deleted_at: 1.minute.ago)
      sign_in user
      get :index

      expect(response).to redirect_to(new_admin_organization_location_path(org1))
    end
  end
end
