require "spec_helper"

describe MarketOrganization do
  describe "soft_delete" do
    include_context "soft delete-able models"
    it_behaves_like "a soft deleted model"
  end
end
