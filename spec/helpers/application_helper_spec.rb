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
        expect(path_to_my_organization).to eq(organizations_path)
      end
    end
  end

  describe "#color_mix" do
    it "mixes colors" do
      expect(color_mix).to eq("hsl(0, 0%, 50%)")
      expect(color_mix("#ffffff", 0)).to eq("hsl(0, 100%, 100%)")
      expect(color_mix("#000000", 100)).to eq("hsl(0, 0%, 100%)")
      expect(color_mix("000000", 100)).to eq("hsl(0, 0%, 100%)")
      expect(color_mix("#456589", 50)).to eq("hsl(211, 33%, 90%)")
    end
  end
end
