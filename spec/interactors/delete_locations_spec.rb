require 'spec_helper'

describe DeleteLocations do
  let(:organization) { create(:organization, :buyer) }
  let(:location)     { create(:location, organization: organization) }
  let(:market)       { create(:market, organizations: [organization]) }

  describe '.perform' do
    context 'when two locations exist' do
      let(:new_location) { create(:location, organization: organization) }

      it 'deleting both succeeds' do
        DeleteLocations.perform(organization: organization, location_ids: [location.id, new_location.id])

        location.reload
        new_location.reload
        expect(location.deleted_at).to_not be_nil
        expect(new_location.deleted_at).to_not be_nil
      end

      it 'deleting the default location makes the first remaining location the default' do
        DeleteLocations.perform(organization: organization, location_ids: [location.id])

        new_location.reload
        expect(new_location).to be_default_billing
        expect(new_location).to be_default_shipping
      end
    end
  end
end