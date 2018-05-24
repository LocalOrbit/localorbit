require 'spec_helper'

RSpec.describe UpdateDeliverySchedulesForProduct do
  let!(:market)             { create(:market) }
  let!(:monday_delivery)    { create(:delivery_schedule, market: market, day: 1) }

  let!(:market2)            { create(:market) }
  let!(:wednesday_delivery) { create(:delivery_schedule, market: market2, day: 3) }

  subject(:perform) { described_class.perform(product: product) }

  context 'using all deliveries' do
    context 'single market membership' do
      let!(:organization) { create(:organization, :seller, markets: [market]) }
      let!(:product) { create(:product, organization: organization) }

      it 'adds all deliveries' do
        perform
        expect(product.delivery_schedules.count).to eql(1)
        expect(product.delivery_schedules).to include(monday_delivery)
      end
    end

    context 'multi-market membership' do
      let!(:organization) { create(:organization, :seller, markets: [market, market2]) }
      let!(:product) { create(:product, organization: organization) }

      it 'adds all deliveries' do
        perform
        expect(product.delivery_schedules.count).to eql(2)
        expect(product.delivery_schedules).to include(monday_delivery, wednesday_delivery)
      end
    end
  end

  context 'manually managing deliveries' do
    context 'single market membership' do
      let!(:organization) { create(:organization, :seller, markets: [market]) }
      let!(:product) { create(:product, use_all_deliveries: false, organization: organization) }

      it 'does not automatically add delivery schedules' do
        perform
        expect(product.delivery_schedules.count).to eql(0)
      end

      it 'allows unselecting all delivery schedules' do
        product.delivery_schedules = [monday_delivery]
        perform
        expect(product.delivery_schedules.count).to eql(1)

        product.delivery_schedule_ids = []
        perform
        expect(product.reload.delivery_schedules.count).to eql(0)
      end
    end

    context 'multi-market membership' do
      let!(:organization) { create(:organization, :seller, markets: [market, market2]) }
      let!(:product) { create(:product, use_all_deliveries: false, organization: organization) }

      it 'does not automatically add delivery schedules' do
        perform
        expect(product.delivery_schedules.count).to eql(0)
      end

      it 'removes delivery schedules from markets that are not part of the organization' do
        product.delivery_schedules = [monday_delivery, wednesday_delivery]
        organization.markets = [market]
        perform
        product.reload

        expect(product.delivery_schedules.count).to eql(1)
        expect(product.delivery_schedules).to include(monday_delivery)
        expect(product.delivery_schedules).to_not include(wednesday_delivery)
      end

      it 'allows unselecting all delivery schedules' do
        product.delivery_schedules = [monday_delivery, wednesday_delivery]
        perform
        expect(product.delivery_schedules.count).to eql(2)

        product.delivery_schedule_ids = []
        product.save
        perform
        expect(product.reload.delivery_schedules.count).to eql(0)
      end
    end
  end

end
