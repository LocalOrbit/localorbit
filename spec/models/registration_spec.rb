require "spec_helper"

# TODO: THIS CLASS NEEDS MORE UNIT TESTS!
describe Registration do
  let(:market) { create(:market) }

  let(:registration_attrs) {
    {
      market: market,
      name: 'My Name',
      contact_name: "My Contact Name",
      address: "123 W Ave",
      city: "A2",
      state: "MI",
      zip: "12345",
      email: "an@example.com",
      password: "password1",
      password_confirmation: "password1"
    }
  }

  let(:registration) {
    Registration.new(registration_attrs)
  }

  context "market does have 'auto-activate organizations' enabled" do
    let(:market) { create(:market,  auto_activate_organizations: true ) }
    it "should have a registration organization is enabled" do
      registration.save
      org = registration.organization
      user = registration.user
      expect(user.enabled_for_organization? org).to be true
      expect(org.active?).to be true
    end
  end

  context "market does *not* have 'auto-activate organizations' enabled" do
    it "should have a registered organization that is not be enabled" do
      registration.save
      org = registration.organization
      user = registration.user
      expect(user.enabled_for_organization? org).to be true
      expect(org.active?).to be false
    end
  end

  describe "address_label" do
    it "saves Location name based on address_label" do
      label = "The Address Label"
      registration_attrs[:address_label] = label

      expect(registration.save).to be true

      expect(registration.organization.locations.first.name).to eq(label)
    end

    it "defaults to 'Default Address' when saving a new Location" do
      registration_attrs[:address_label] = nil

      success = registration.save
      expect(success).to be true

      expect(registration.organization.locations.first.name).to eq("Default Address")
    end
  end
end
