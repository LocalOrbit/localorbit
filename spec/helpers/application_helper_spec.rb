require "spec_helper"

describe ApplicationHelper do
  describe "#path_to_my_organization" do
    context "a user with 1 managed organization" do
      let(:organization) { double(:organization, to_param: "123") }
      let(:current_user) { double(:user, managed_organizations: [organization]) }

      it "returns the url to the organization" do
        expect(path_to_my_organization).to eq(admin_organization_path(organization))
      end
    end

    context "a user with multiple managed organization" do
      let(:current_user) { double(:user, managed_organizations: [build(:organization), build(:organization)]) }

      it "returns the url to the organizations" do
        expect(path_to_my_organization).to eq(admin_organizations_path)
      end
    end
  end

  describe "#color_mix" do
    it "mixes colors" do
      expect(color_mix).to eq("#d2d2d2")
      expect(color_mix("#ffffff", "#ffffff")).to eq("#ffffff")
      expect(color_mix("#000000", "#ffffff")).to eq("#d2d2d2")
      expect(color_mix("000000", "ffffff")).to eq("#d2d2d2")
    end
  end
end
