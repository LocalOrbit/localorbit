require "spec_helper"

describe Admin::ReportsController do
  let!(:market) { create(:market) }

  before do
    switch_to_subdomain market.subdomain
  end

  describe "#total_sales" do
    it_behaves_like "an action restricted to admin or market manager", lambda { get :total_sales }
  end
end
