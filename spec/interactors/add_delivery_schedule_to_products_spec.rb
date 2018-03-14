require 'spec_helper'

describe AddDeliveryScheduleToProducts do
  let!(:market)        { create(:market) }
  let!(:org1)          { create(:organization, :seller, markets: [market]) }
  let!(:org2)          { create(:organization, markets: [market]) }
  let!(:delivery_schedule) { create(:delivery_schedule) }

  context 'when products exist' do
    let!(:org1_product1) { create(:product, :sellable, organization: org1) }
    let!(:org1_product2) { create(:product, :sellable, organization: org1, use_all_deliveries: false) }
    let!(:org2_product)  { create(:product, :sellable, organization: org2) }

    subject! { AddDeliveryScheduleToProducts.perform(delivery_schedule: delivery_schedule, market: market) }

    it 'adds the delivery schedule to products that use all deliveries' do
      expect(org1_product1.reload.delivery_schedules).to include(delivery_schedule)
      expect(org1_product2.reload.delivery_schedules).to_not include(delivery_schedule)
    end

    it 'adds the delivery schedule to products regardless of organization selling status' do
      expect(org2_product.reload.delivery_schedules).to include(delivery_schedule)
    end
  end

  context 'when no products exist' do
    subject(:perform) { AddDeliveryScheduleToProducts.perform(delivery_schedule: delivery_schedule, market: market) }

    it 'returns success' do
      expect(perform.success?).to be true
    end
  end

end
