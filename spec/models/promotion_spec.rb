require 'spec_helper'

describe Promotion do
  context "validations" do
    subject { Promotion.new }

    it "requires a name" do
      expect(subject).to have(1).error_on(:name)
    end

    it "requires a title" do
      expect(subject).to have(1).error_on(:title)
    end

    it "requires a product" do
      expect(subject).to have(1).error_on(:product)
    end

    it "requires a market" do
      expect(subject).to have(1).error_on(:market)
    end

    it "requires there only be one active per market" do
      create_list(:promotion, 3)
      existing = create(:promotion, :active)

      subject = build(:promotion, :active, market: existing.market)

      expect(subject).to have(1).error_on(:active)
    end
  end
end
