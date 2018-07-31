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

  describe '#save' do
    describe "address_label" do
      it "saves Location name based on address_label" do
        label = "The Address Label"
        registration_attrs[:address_label] = label

        success = registration.save
        expect(success).to be true

        expect(registration.organization.locations.first.name).to eq(label)
      end

      it "defaults to 'Default Address' when saving a new Location" do
        registration_attrs[:address_label] = nil

        success = registration.save
        expect(success).to be true

        expect(registration.organization.locations.first.name).to eq("Default Address")
      end
    end

    describe 'user' do
      it 'belongs to proper organization' do
        success = registration.save
        expect(success).to be true

        expect(registration.user.organizations).to include(registration.organization)
      end

      it 'password is valid' do
        success = registration.save
        expect(success).to be true

        expect(registration.user.valid_password?('password1')).to be_truthy
      end
    end
  end
end
