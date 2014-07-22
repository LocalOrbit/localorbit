require "spec_helper"

describe Admin::ReportsController do
  let!(:market) { create(:market) }

  before do
    switch_to_subdomain market.subdomain
  end

  it_behaves_like "an action that restricts access to non buyers only", lambda { get :show, id: "total-sales" }
  it_behaves_like "an action that restricts access to non buyers only", lambda { get :show, id: "sales-by-seller" }
  it_behaves_like "an action that restricts access to non buyers only", lambda { get :show, id: "sales-by-product" }
  it_behaves_like "an action that restricts access to non buyers only", lambda { get :show, id: "sales-by-payment-method" }
  it_behaves_like "an action that restricts access to non-sellers only", lambda { get :show, id: "purchases-by-product" }
  it_behaves_like "an action that restricts access to non-sellers only", lambda { get :show, id: "total-purchases" }
end
