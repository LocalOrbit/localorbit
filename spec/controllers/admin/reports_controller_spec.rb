require "spec_helper"

describe Admin::ReportsController do
  let!(:market) { create(:market) }

  before do
    switch_to_subdomain market.subdomain
  end

  it_behaves_like "an action that restricts access admin, market manager, or seller only", lambda { get :total_sales }
end
