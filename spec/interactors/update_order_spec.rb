require "spec_helper"

describe UpdateOrder do
  let!(:user) { build(:user) }
  let!(:market) { create(:market) }
  let!(:order) { create(:order, market: market) }

  context "#perform" do
    it "calls the appropriate interactors" do
      expect(UpdateQuantities).to receive(:perform)
      expect(StoreOrderFees).to receive(:perform)
      expect(UpdatePurchase).to receive(:perform)
      expect(ClearInvoicePdf).to receive(:perform)

      described_class.perform(payment_provider: 'stripe', order: order)
    end
  end
end
