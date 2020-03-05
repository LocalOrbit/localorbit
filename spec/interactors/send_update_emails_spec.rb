require "spec_helper"

describe SendUpdateEmails do
  let!(:market)       { create(:market) }

  let!(:seller1)      { create(
                          :organization,
                          :seller,
                          name: 'seller1',
                          markets: [market]) }

  let!(:seller1_user) { create(
                          :user,
                          :supplier,
                          organizations: [seller1]) }

  let!(:product1)     { create(
                          :product,
                          :sellable,
                          organization: seller1) }

  let!(:seller2)      { create(
                          :organization,
                          :seller,
                          name: 'seller2',
                          markets: [market]) }

  let!(:seller2_user) { create(
                          :user,
                          :supplier,
                          organizations: [seller2]) }

  let!(:product2)     { create(
                          :product,
                          :sellable,
                          organization: seller2) }

  let!(:buyer)        { create(
                          :organization,
                          :buyer,
                          markets: [market]) }

  let!(:buyer_user)   { create(
                          :user,
                          :buyer,
                          organizations: [buyer]) }

  let!(:order)        { create(
                          :order,
                          market: market,
                          organization: buyer) }

  let!(:item1)        { create(
                          :order_item,
                          product: product1,
                          unit_price: 2.00,
                          quantity: 4,
                          order: order) }

  let!(:item2)        { create(
                          :order_item,
                          product: product2,
                          unit_price: 4.00,
                          quantity: 2,
                          order: order) }

  let(:update_params) { { updated_at: Time.current } }

  let!(:plan)         { create(:plan, :accelerate) }

  before do
    Order.enable_auditing
    OrderItem.enable_auditing

    order.reload.update(update_params)

    OrderItem.disable_auditing
    Order.disable_auditing

    # Set all audits to be the same request
    Audit.all.update_all(request_uuid: SecureRandom.uuid)
  end

  context 'a update that should send an email' do
    let!(:update_params) do
      {
        updated_at: Time.current,
        items_attributes: {
          '0' => {
            id: item1.id,
            quantity: 5
          }
        }
      }
    end

    it 'sends an email to sellers whose items have been updated' do
      request = @request
      if order.market.organization.plan == plan
        expect_any_instance_of(OrderMailer).to receive(:seller_order_updated)
        SendUpdateEmails.perform(order: order, request: request)
      end
    end

    it 'does not send an email to sellers whose items have not been updated' do
      request = @request
      expect_any_instance_of(OrderMailer).to_not receive(:seller_order_updated).with(order, seller2, nil, nil)
      SendUpdateEmails.perform(order: order, request: request)
    end
  end

  context 'a update that should not send emails' do
    let!(:update_params) do
      {
        updated_at: Time.current,
        items_attributes: {
          '0' => {
            id: item1.id,
            quantity_delivered: 4
          }
        }
      }
    end

    it 'does not send an email to users in the organization' do
      request = @request
      expect_any_instance_of(OrderMailer).not_to receive(:buyer_order_updated)

      SendUpdateEmails.perform(request: request, order: order)
    end

    it 'does not send an email to sellers whose items have not been updated' do
      request = @request
      expect_any_instance_of(OrderMailer).not_to receive(:seller_order_updated)

      SendUpdateEmails.perform(request: request, order: order)
    end
  end
end
