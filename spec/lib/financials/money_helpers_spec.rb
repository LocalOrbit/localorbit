describe Financials::MoneyHelpers do
  subject(:helper) { described_class }

  describe ".amount_to_cents" do
    it "returns integer representing number of cents in the given decimal dollar amount" do
      expect(helper.amount_to_cents(1)).to eq 100
      expect(helper.amount_to_cents(13.13)).to eq 1313
      expect(helper.amount_to_cents("42.42".to_d)).to eq 4242
      expect(helper.amount_to_cents(0)).to eq 0
    end
  end
  
end
