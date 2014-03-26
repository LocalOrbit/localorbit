require "spec_helper"

describe ApplicationHelper do
  describe "#path_to_my_orgainzation" do
    context "a user with 1 managed organization" do
      let(:organization) { double(:organization, to_param: "123") }
      let(:current_user) { double(:user, managed_organizations: [organization]) }

      it "returns the url to the orgainzation" do
        expect(path_to_my_orgainzation).to eq(admin_organization_path(organization))
      end
    end

    context "a user with multiple managed organization" do
      let(:current_user) { double(:user, managed_organizations: [build(:organization), build(:organization)]) }

      it "returns the url to the orgainzations" do
        expect(path_to_my_orgainzation).to eq(admin_organizations_path)
      end
    end
  end
end
