require "spec_helper"

describe SendOrderEmails do
  let(:buyer)  { create(:organization, :buyer, users:[create(:user)]) }
  let(:seller) { create(:organization, :seller, users:[create(:user)]) }
  let(:market) { create(:market, managers: [create(:user)]) }

  let(:product) { create(:product, :sellable, organization: seller) }
  let(:order)  { create(:order, market: market, organization: buyer) }
  let!(:order_item) {create(:order_item, product: product, order: order) }

  context "when a seller has no users" do
    let(:seller) { create(:organization, :seller) }

    it "sends no emails to the selling organization" do
      expect {
        SendOrderEmails.perform(order: order, seller: seller)
      }.not_to raise_error

      expect(ActionMailer::Base.deliveries.count).to eql(2)
    end
  end

  context "when a buyer has no users" do
    let(:buyer) { create(:organization, :buyer) }

    it "sends no emails to the buying organization" do
      expect {
        SendOrderEmails.perform(order: order, seller: seller)
      }.not_to raise_error

      expect(ActionMailer::Base.deliveries.count).to eql(2)
    end
  end

  context "when a market has no users" do
    let(:market) { create(:market) }

    it "sends no emails to the market managers" do
      expect {
        SendOrderEmails.perform(order: order, seller: seller)
      }.not_to raise_error

      expect(ActionMailer::Base.deliveries.count).to eql(2)
    end
  end
end
