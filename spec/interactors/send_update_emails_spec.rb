require "spec_helper"

describe SendUpdateEmails do
  let!(:market) { create(:market) }

  let!(:seller1) { create(:organization, :seller, markets: [market]) }
  let!(:product1) { create(:product, :sellable, organization: seller1) }
  let!(:seller_user1)    { create(:user, organizations: [seller1]) }

  let!(:seller2) { create(:organization, :seller, markets: [market]) }
  let!(:product2) { create(:product, :sellable, organization: seller2) }
  let!(:seller_user2) { create(:user, organizations: [seller2]) }

  let!(:buyer) { create(:organization, :buyer, markets: [market]) }
  let!(:buyer_user) { create(:user, organizations: [buyer]) }

  let!(:order)    { create(:order, market: market, organization: buyer) }
  let!(:item1)    { create(:order_item, product: product1, unit_price: 2.00, quantity: 4, order: order) }
  let!(:item2)    { create(:order_item, product: product2, unit_price: 4.00, quantity: 2, order: order) }

  let(:update_params) { { updated_at: Time.current } }

  before do
    Order.enable_auditing
    OrderItem.enable_auditing

    order.reload.update(update_params)
    # UpdateQuantities.perform(order: order.reload, order_params: update_params)

    OrderItem.disable_auditing
    Order.disable_auditing

    # Set all audits to be the same request
    Audit.all.update_all(request_uuid: SecureRandom.uuid)
  end

  context "a update that should send an email" do
    let!(:update_params) do
      {
        updated_at: Time.current,
        items_attributes: {
          "0" => {
            id: item1.id,
            quantity: 5
          }
        }
      }
    end

    it "sends an email to users in the organization" do
      request = @request
      expect_any_instance_of(OrderMailer).to receive(:buyer_order_updated).with(order)

      SendUpdateEmails.perform(order: order, request: request)
    end

    it "sends an email to sellers whose items have been updated" do
      request = @request

      expect_any_instance_of(OrderMailer).to receive(:seller_order_updated) #.with(order, seller1, pdf, csv)

      SendUpdateEmails.perform(order: order, request: request)
    end

    it "does not send an email to sellers whose items have not been updated" do
      request = @request

      expect_any_instance_of(OrderMailer).to_not receive(:seller_order_updated).with(order, seller2, nil, nil)

      SendUpdateEmails.perform(order: order, request: request)
    end
  end

  context "when an order item has been deleted" do
    let!(:update_params) do
      {
        items_attributes: {
          "0"=>{
            id: item1.id.to_s,
            quantity: "2",
            "_destroy" => "true"
          }
        }
      }
    end

    it "sends an email to users in the organization" do
      expect_any_instance_of(OrderMailer).to receive(:buyer_order_updated).with(order)
      request = @request

      expect {
        SendUpdateEmails.perform(order: order, request: request)
      }.to_not raise_error
    end
  end

  context "a update that should not send emails" do
    let!(:update_params) do
      {
        updated_at: Time.current,
        items_attributes: {
          "0" => {
            id: item1.id,
            quantity_delivered: 4
          }
        }
      }
    end

    it "does not send an email to users in the organization" do
      request = @request
      expect_any_instance_of(OrderMailer).not_to receive(:buyer_order_updated)

      SendUpdateEmails.perform(request: request, order: order)
    end

    it "does not send an email to sellers whose items have not been updated" do
      request = @request
      expect_any_instance_of(OrderMailer).not_to receive(:seller_order_updated)

      SendUpdateEmails.perform(request: request, order: order)
    end
  end
end
