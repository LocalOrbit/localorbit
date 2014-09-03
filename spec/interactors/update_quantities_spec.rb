require "spec_helper"

describe UpdateQuantities do
  let!(:order) { create(:order) }
  let!(:item1) { create(:order_item, unit_price: 2.00, quantity: 4, order: order) }
  let!(:item2) { create(:order_item, unit_price: 4.00, quantity: 2, order: order) }

  context "updating successfully" do
    let(:params) {
      {
        items_attributes: {
          "0" => {
            id: item1.id,
            quantity_delivered: item1.quantity
          }
        }
      }
    }

    before do
      order.reload
      @interactor = UpdateQuantities.perform(order: order, order_params: params)
    end

    it "updates quantities" do
      expect(@interactor).to be_success
    end

    it "updates the order's delivery status" do
      expect(order.delivery_status).to eq("partially delivered")
    end

  end

end