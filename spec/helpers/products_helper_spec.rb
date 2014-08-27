require "spec_helper"

describe ProductsHelper do
  describe "#inventory_tab_complete?" do
    it "returns true if available inventory is > 0" do
      @product = double(:product, available_inventory: 1)
      expect(inventory_tab_complete?).to be(true)
    end

    it "returns false if available inventory is 0" do
      @product = double(:product, available_inventory: 0)
      expect(inventory_tab_complete?).to be(false)
    end
  end
end
