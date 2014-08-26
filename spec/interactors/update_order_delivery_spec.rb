require "spec_helper"

describe UpdateOrderDelivery do
  let!(:user) { build(:user) }
  let!(:market) { create(:market) }
  let!(:delivery) do
    create(:delivery, delivery_schedule:
    create(:delivery_schedule, buyer_pickup_location: create(:market_address, market: market)
  ))
  end
  let!(:order) { create(:order, delivery: delivery, market: market) }

  context "saving successfully" do
    it "saves the new delivery on the order" do
      expect(order).to receive(:valid?).and_return(true)
      expect(order).to receive(:save).and_return(true)
      UpdateOrderDelivery.perform(user: user, order: order, delivery_id: delivery.id)
    end
  end

  context "saving is unsuccessful" do
    it "notifies honeybadger" do
      expect(order).to receive(:valid?).and_return(false)
      expect(order).not_to receive(:save)
      expect(Honeybadger).to receive(:notify)
      expect(ZendeskMailer).to receive(:error_intervention).and_return(double(:user_mailer, deliver: true))
      UpdateOrderDelivery.perform(user: user, order: order, delivery_id: delivery.id)
    end
  end

  context "trouble changing delivery location" do
    let!(:delivery2) do
      create(:delivery, delivery_schedule:
      create(:delivery_schedule, buyer_pickup_location: nil)
    )
    end

    before do
      2.times { create(:location, organization: order.organization) }
    end

    it "fails and notifies" do
      expect(order).not_to receive(:save)
      expect(Honeybadger).to receive(:notify)
      expect(ZendeskMailer).to receive(:error_intervention).and_return(double(:user_mailer, deliver: true))
      UpdateOrderDelivery.perform(user: user, order: order, delivery_id: delivery2.id)
    end
  end
end
