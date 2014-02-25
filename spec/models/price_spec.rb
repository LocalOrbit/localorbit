require 'spec_helper'

describe Price do
  describe '#net_price' do
    it "returns the adjusted sale_price for fees" do
      expect(subject.net_price).to eq(0)

      subject.sale_price = 1.99

      expect(subject.net_price).to eq(1.93) # 3% fees

      subject.sale_price = 3.99

      expect(subject.net_price).to eq(3.87) # 3% fees
    end
  end
end
