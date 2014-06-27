require "spec_helper"

describe UpdateOrderDelivery do
  let!(:order) { build(:order) }

  context "saving successfully" do
    it "saves the new delivery on the order" do
      expect(order).to receive(:valid?).and_return(true)
      expect(order).to receive(:save).and_return(true)
      UpdateOrderDelivery.perform(order: order, delivery_id: 123)
    end
  end

  context "saving is unsuccessful" do
    it "notifies honeybadger" do
      expect(order).to receive(:valid?).and_return(false)
      expect(order).not_to receive(:save)
      expect(Honeybadger).to receive(:notify)
      UpdateOrderDelivery.perform(order: order, delivery_id: 123)
    end
  end
end