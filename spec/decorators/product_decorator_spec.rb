require "spec_helper"

describe ProductDecorator do
  describe "#has_custom_seller_info?" do
    it "returns false if the product has no custom seller info" do
      product = build(:product, :decorated)

      expect(product.has_custom_seller_info?).to be false
    end

    it "returns true if the product has a custom who story" do
      product = build(:product, :decorated, who_story: "who")

      expect(product.has_custom_seller_info?).to be true
    end

    it "returns true if the product has a custom how story" do
      product = build(:product, :decorated, how_story: "how")

      expect(product.has_custom_seller_info?).to be true
    end

    it "returns true if the product has a custom location" do
      product = build(:product, :decorated, location_id: 1)

      expect(product.has_custom_seller_info?).to be true
    end
  end

  describe "#location_options_for_select" do
    it "returns an empty set for a new product" do
      product = build(:product, :decorated, organization: nil)

      expect(product.location_options_for_select).to be_empty
    end

    it "returns the product's organization's locations for an existing product" do
      organization = create(:organization)

      create(:location, name: "Deleted Location", id: 4, organization: organization, deleted_at: 1.minute.ago)
      create(:location, name: "Location 1", id: 1, organization: organization)
      create(:location, name: "Location 2", id: 2, organization: organization)
      create(:location, name: "Location 3", id: 3, organization: organization)
      organization.locations.update_all(default_billing: false, default_shipping: false)
      organization.locations.find(3).update!(default_shipping: true)

      product = create(:product, :decorated, organization: organization)

      expect(product.location_options_for_select).to eq([
        ["Location 3", 3],
        ["Location 1", 1],
        ["Location 2", 2]
      ])
    end
  end

  describe "custom seller info" do
    let(:organization) do
      build(:organization, who_story: "org-who", how_story: "org-how")
    end

    describe "#who_story" do
      it "returns custom who story when available" do
        product = build(:product, :decorated, organization: organization, who_story: "prod-who")

        expect(product.who_story).to eq("prod-who")
      end

      it "returns the organization's who story when custom who story unavailable" do
        product = build(:product, :decorated, organization: organization, who_story: nil)

        expect(product.who_story).to be_nil
      end

      it "returns nil when the product has no organization" do
        product = build(:product, :decorated)

        expect(product.who_story).to be_nil
      end
    end

    describe "#how_story" do
      it "returns custom how story when available" do
        product = build(:product, :decorated, organization: organization, how_story: "prod-how")

        expect(product.how_story).to eq("prod-how")
      end

      it "returns the organization's how story when custom how story unavailable" do
        product = build(:product, :decorated, organization: organization, how_story: nil)

        expect(product.how_story).to be_nil
      end

      it "returns nil when the product has no organization" do
        product = build(:product, :decorated)

        expect(product.how_story).to be_nil
      end
    end

    describe "#location" do
      it "returns custom location when available" do
        organization_other_location = create(:location, organization: organization)

        product = build(:product, :decorated, organization: organization, location: organization_other_location)

        expect(product.location).to eq(organization_other_location)
      end

      it "returns the organization's default location when custom location unavailable" do
        create(:location, organization: organization, deleted_at: 1.minute.ago)
        organization_default_location = create(:location, organization: organization)

        product = build(:product, :decorated, organization: organization, location: nil)

        expect(product.location).to be_nil
      end

      it "returns nil when the product has no organization" do
        product = build(:product, :decorated)

        expect(product.location).to be_nil
      end
    end
  end
end
