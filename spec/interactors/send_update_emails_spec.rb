require "spec_helper"

describe SendUpdateEmails do
  let!(:market)   { create(:market) }

  let!(:seller1)  { create(:organization, :seller, markets: [market]) }
  let!(:product1) { create(:product, :sellable, organization: seller1) }
  let!(:user1)    { create(:user, organizations: [seller1]) }

  let!(:seller2)  { create(:organization, :seller, markets: [market]) }
  let!(:product2) { create(:product, :sellable, organization: seller2) }
  let!(:user2)    { create(:user, organizations: [seller2]) }

  let!(:buyer)    { create(:organization, :buyer, markets: [market]) }
  let!(:user3)    { create(:user, organizations: [buyer]) }

  let!(:order)    { create(:order, market: market, organization: buyer) }
  let!(:item1)    { create(:order_item, product: product1, unit_price: 2.00, quantity: 4, order: order) }
  let!(:item2)    { create(:order_item, product: product2, unit_price: 4.00, quantity: 2, order: order) }

  before do
    Order.enable_auditing
    OrderItem.enable_auditing
    order.reload.update(updated_at: Time.current, items_attributes: {"0" => {id: item1.id, quantity: 5}})
    OrderItem.disable_auditing
    Order.disable_auditing

    Audit.all.update_all(request_uuid: SecureRandom.uuid)
  end

  it "sends an email to users in the organization" do
    expect_any_instance_of(OrderMailer).to receive(:buyer_order_updated).with(order)

    SendUpdateEmails.perform(order: order)
  end

  it "sends an email to sellers whose items have been updated" do
    expect_any_instance_of(OrderMailer).to receive(:seller_order_updated).with(order, seller1)

    SendUpdateEmails.perform(order: order)
  end

  it "does not send an email to sellers whose items have not been updated" do
    expect_any_instance_of(OrderMailer).to_not receive(:seller_order_updated).with(order, seller2)

    SendUpdateEmails.perform(order: order)
  end

  context "when an order item has been deleted" do
    before do
      params = {
        "notes"=>"",
        "items_attributes" => {
          "0"=>{"id"=>item1.id.to_s, "quantity"=>"2", "quantity_delivered"=>"", "delivery_status"=>"pending", "_destroy"=>"true"},
        }
      }

      Order.enable_auditing
      OrderItem.enable_auditing

      UpdateQuantities.perform(order: order, order_params: params)

      Order.disable_auditing
      OrderItem.disable_auditing
      Audit.all.update_all(request_uuid: SecureRandom.uuid)
    end

    it "sends an email to users in the organization" do
      expect_any_instance_of(OrderMailer).to receive(:buyer_order_updated).with(order)
      expect {
        SendUpdateEmails.perform(order: order)
      }.to_not raise_error
    end
  end

end
