require "spec_helper"

describe Admin::ReportsController do
  let!(:market) { create(:market) }

  before do
    switch_to_subdomain market.subdomain
  end

  it_behaves_like "an action that restricts access to non buyers only", lambda { get :show, report: "total-sales" }
  it_behaves_like "an action that restricts access to non buyers only", lambda { get :show, report: "sales-by-seller" }
  it_behaves_like "an action that restricts access to non buyers only", lambda { get :show, report: "sales-by-product" }
  it_behaves_like "an action that restricts access to non buyers only", lambda { get :show, report: "sales-by-payment-method" }
  it_behaves_like "an action that is accessible to all roles", lambda { get :show, report: "purchases-by-product" }
  it_behaves_like "an action that is accessible to all roles", lambda { get :show, report: "total-purchases" }
end
