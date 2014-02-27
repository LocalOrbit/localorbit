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

  describe 'view_sorted' do
    let(:product) { create(:product) }

    it 'has all buyers before a buyer specific price' do
      p2 = product.prices.create(min_quantity: 5, sale_price: 2)
      p3 = product.prices.create(organization: create(:organization), sale_price: 3)
      p1 = product.prices.create(sale_price: 2)

      expect(product.prices.view_sorted).to eq([p1, p2, p3])
    end

    it 'has buyer specific pricing ordered by buyer name' do
      org1 = create(:organization, name: 'Organic Farms')
      org2 = create(:organization, name: 'Better Farms')

      p2 = product.prices.create(organization: org2, sale_price: 2)
      p3 = product.prices.create(organization: org1, sale_price: 2)
      p1 = product.prices.create(sale_price: 2)

      expect(product.prices.view_sorted).to eq([p1, p2, p3])
    end
  end
end
