require 'spec_helper'

describe Financials::MoneyHelpers do
  subject(:subject) { described_class }

  describe ".amount_to_cents" do
    it "returns integer representing number of cents in the given decimal dollar amount" do
      expect(subject.amount_to_cents(1)).to eq 100
      expect(subject.amount_to_cents(13.13)).to eq 1313
      expect(subject.amount_to_cents("42.42".to_d)).to eq 4242
      expect(subject.amount_to_cents(0)).to eq 0
      expect(subject.amount_to_cents(nil)).to eq 0
    end
  end

  describe ".cents_to_amount" do
    it "returns a BigDecimal representing the dollar form of the given integer cent total" do
      expect(subject.cents_to_amount(0)).to eq "0.0".to_d
      expect(subject.cents_to_amount(1)).to eq "0.01".to_d
      expect(subject.cents_to_amount(123)).to eq "1.23".to_d
      expect(subject.cents_to_amount(250)).to eq "2.5".to_d
      expect(subject.cents_to_amount(9999)).to eq "99.99".to_d
      expect(subject.cents_to_amount(nil)).to eq "0".to_d
    end
  end
  
end
