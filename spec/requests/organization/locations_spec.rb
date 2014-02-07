require "spec_helper"

describe "GET /index" do
  def location_json(location)
    {
      "id"      => location.id,
      "name"    => location.name,
      "address" => location.address,
      "city"    => location.city,
      "state"   => location.state,
      "zip"     => location.zip
    }
  end

  let(:user)           { create(:user) }
  let(:admin)          { create(:user, :admin) }
  let(:market_manager) { create(:user, :market_manager) }

  let(:organization)   { create(:organization) }
  let!(:locations)     { create_list(:location, 2, organization: organization) }

  context "when a user is not logged in" do
    it "returns a 401" do
      get organization_locations_path(organization, format: :json)

      expect(response.status).to eq(401)
    end
  end

  context "when the user is not a member of the organization" do
    it "returns a 404" do
      sign_in_as(user)

      get organization_locations_path(organization, format: :json)

      expect(response.status).to eq(404)
    end
  end

  context "when the user is a member of the organization" do
    before do
      sign_in_as(user)
      user.organizations << organization
    end

    it "returns a list of locations" do
      get organization_locations_path(organization, format: :json)

      expect(response.status).to eq(200)
      expect(response.collection).to include(
        location_json(locations.first),
        location_json(locations.last)
      )
    end
  end

  context "when the user is an admin" do
    before do
      sign_in_as(admin)
    end

    it "returns a list of locations" do
      get organization_locations_path(organization, format: :json)

      expect(response.status).to eq(200)
      expect(response.collection).to include(
        location_json(locations.first),
        location_json(locations.last)
      )
    end
  end

  context "when the user is a market manager" do
    before do
      sign_in_as(market_manager)
    end

    context "and viewing a managed organization" do
      before do
        market_manager.markets.first.organizations << organization
      end

      it "returns a list of locations" do
        get organization_locations_path(organization, format: :json)

        expect(response.status).to eq(200)
        expect(response.collection).to include(
          location_json(locations.first),
          location_json(locations.last)
        )
      end
    end

    context "and not viewing a managed organization" do
      it "returns 404" do
        get organization_locations_path(organization, format: :json)

        expect(response.status).to eq(404)
      end
    end
  end
end
