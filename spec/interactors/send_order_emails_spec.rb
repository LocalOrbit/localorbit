require "spec_helper"

describe SendOrderEmails do
  let(:buyer)  { create(:organization, :buyer, users: [create(:user)]) }
  let(:seller) { create(:organization, :seller, users: [create(:user)]) }
  let(:market) { create(:market, managers: [create(:user)]) }

  let(:product) { create(:product, :sellable, organization: seller) }
  let!(:delivery_schedule) { create(:delivery_schedule) }
  let!(:delivery)    { delivery_schedule.next_delivery }
  let(:order)  { create(:order, placed_by: buyer.users.first, delivery: delivery, items: [create(:order_item, product: product)], market: market, organization: buyer) }

  context "when a seller has no users" do
    let(:seller) { create(:organization, :seller) }

    it "sends no emails to the selling organization" do
      expect {
        SendOrderEmails.perform(order: order, seller: seller)
      }.not_to raise_error

      expect(ActionMailer::Base.deliveries.count).to eql(2)
    end
  end

  context "when a market manager shops for an organizatgion with no users" do
    let(:market_manager) { create(:user, managed_markets: [market]) }
    let(:buyer) { create(:organization, :buyer) }
    let(:order)  { create(:order, placed_by: market_manager, delivery: delivery, items: [create(:order_item, product: product)], market: market, organization: buyer) }

    it "sends no emails to the buying organization" do
      expect {
        SendOrderEmails.perform(request: request, order: order, seller: seller)
      }.not_to raise_error

      expect(ActionMailer::Base.deliveries.count).to eql(2)
    end
  end

  context "when a market has no users" do
    let(:market) { create(:market) }

    it "sends no emails to the market managers" do
      expect {
        SendOrderEmails.perform(request: request, order: order, seller: seller)
      }.not_to raise_error

      expect(ActionMailer::Base.deliveries.count).to eql(2)
    end
  end
end
