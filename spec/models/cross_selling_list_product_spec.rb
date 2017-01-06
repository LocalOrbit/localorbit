require "spec_helper"

describe CrossSellingListProduct do
  context "validations" do
    describe "product_id" do
      it "must be present" do
        list_product = build(:cross_selling_list_product)
        list_product.product_id = nil

        expect(list_product).to_not be_valid
        expect(list_product).to have(1).error_on(:product_id)
      end
    end

    describe "cross_selling_list_id" do
      it "must be present" do
        list_product = build(:cross_selling_list_product)
        list_product.cross_selling_list_id = nil

        expect(list_product).to_not be_valid
        expect(list_product).to have(1).error_on(:cross_selling_list_id)
      end
    end
  end

  context "cross_selling_list_product" do
    let!(:active_cross_selling_list_product) { create(:cross_selling_list_product, :active) }
    let!(:inactive_cross_selling_list_product) { create(:cross_selling_list_product, :inactive) }

    describe ".active?" do
      it "is true for active entries" do
        expect(active_cross_selling_list_product.active?).to be true
      end

      it "is false for inactive entries" do
        expect(inactive_cross_selling_list_product.active?).to be false
      end
    end
  end
end