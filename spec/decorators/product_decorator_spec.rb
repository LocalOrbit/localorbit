require "spec_helper"

describe ProductDecorator do
  describe "#has_custom_seller_info?" do
    it "returns false if the product has no custom seller info" do
      product = build(:product, :decorated)

      expect(product.has_custom_seller_info?).to be_false
    end

    it "returns true if the product has a custom who story" do
      product = build(:product, :decorated, who_story: "who")

      expect(product.has_custom_seller_info?).to be_true
    end

    it "returns true if the product has a custom how story" do
      product = build(:product, :decorated, how_story: "how")

      expect(product.has_custom_seller_info?).to be_true
    end

    it "returns true if the product has a custom location" do
      product = build(:product, :decorated, location_id: 1)

      expect(product.has_custom_seller_info?).to be_true
    end
  end

  describe "#location_options_for_select" do
    it "returns an empty set for a new product" do
      product = build(:product, :decorated, organization: nil)

      expect(product.location_options_for_select).to be_empty
    end

    it "returns the product's organization's locations for an existing product" do
      organization = create(:organization)

      create(:location, name: "Location 1", id: 1, organization: organization)
      create(:location, name: "Location 2", id: 2, organization: organization)

      product = create(:product, :decorated, organization: organization)

      expect(product.location_options_for_select).to eq([
        ["Location 1", 1],
        ["Location 2", 2]
      ])
    end
  end
end
