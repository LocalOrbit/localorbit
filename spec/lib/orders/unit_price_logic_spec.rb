require 'spec_helper'

describe Orders::UnitPriceLogic do
  subject(:logic) {described_class}

  let(:order) { build(:order, market: create(:market)) }
  let(:market) { order.market }
  let(:organization) { order.organization }

  let(:prices) do
    [ 
      create(:price, min_quantity: 1, sale_price: 3),
      create(:price, min_quantity: 5, sale_price: 2),
      create(:price, min_quantity: 8, sale_price: 1) 
    ]
  end

  let(:product) do
    create(:product, lots: [
        create(:lot, quantity: 3),
        create(:lot, quantity: 5)
      ],
      prices: prices
    )
  end

  describe ".unit_price" do
    it 'returns the appropriate price for a given quantity' do
      expect(logic.unit_price(product, order.market, order.organization, DateTime.now, 1).sale_price).to eql(3)
      expect(logic.unit_price(product, order.market, order.organization, DateTime.now, 5).sale_price).to eql(2)
      expect(logic.unit_price(product, order.market, order.organization, DateTime.now, 8).sale_price).to eql(1)
    end

    it "uses the prices that were valid at a given time, not the current pricing" do
      expect(logic.unit_price(product, order.market, order.organization, DateTime.now, 1).sale_price).to eql(3)
      order_time = DateTime.now
      Timecop.travel(order_time + 2.days) do
        Price.soft_delete(product.prices.first)
        Price.create!(min_quantity: 1, sale_price: 5, product: product)
        expect(logic.unit_price(product, order.market, order.organization, order_time, 1).sale_price).to eql(3)
        expect(logic.unit_price(product, order.market, order.organization, order_time, 5).sale_price).to eql(2)
        expect(logic.unit_price(product, order.market, order.organization, order_time, 8).sale_price).to eql(1)
      end
    end

    describe "when there are organization-specific prices set" do

      let(:order_time) { Time.current }

      let(:prices) do
        [
          create(:price, min_quantity: 1, sale_price: "2.5".to_d, organization: organization),
          create(:price, min_quantity: 4, sale_price: ".75".to_d, organization: organization),
          create(:price, min_quantity: 1, sale_price: 3),
          create(:price, min_quantity: 5, sale_price: 2),
          create(:price, min_quantity: 8, sale_price: 1),
        ]
      end

      it "considers the org-specific pricing before more generic prices" do
        [ 0, 1, 3 ].each do |quantity|
          price =  logic.unit_price(product, market, organization, order_time, quantity)
          expect(price.sale_price).to eql("2.5".to_d)
        end
        [ 4, 10 ].each do |quantity|
          price =  logic.unit_price(product, market, organization, order_time, quantity)
          expect(price.sale_price).to eql("0.75".to_d)
        end
      end

      it "returns generic pricing when org doesn't have special pricing" do
        other_org = double "other org", id: organization.id+1
        
        [ 0,1,4 ].each do |quantity|
          price =  logic.unit_price(product, market, other_org, order_time, quantity)
          expect(price.sale_price).to eql(3)
        end

        [ 5,7 ].each do |quantity|
          price =  logic.unit_price(product, market, other_org, order_time, quantity)
          expect(price.sale_price).to eql(2)
        end

        [ 8,20 ].each do |quantity|
          price =  logic.unit_price(product, market, other_org, order_time, quantity)
          expect(price.sale_price).to eql(1)
        end

      end

      describe "when the org-specific pricing has unmet quantity threshold" do
        let(:prices) do
          [
            create(:price, min_quantity: 5, sale_price: "2.5".to_d, organization: organization),
            create(:price, min_quantity: 1, sale_price: 5),
            create(:price, min_quantity: 3, sale_price: 4),
            create(:price, min_quantity: 8, sale_price: 3),
          ]
        end

        it "falls back to the generic pricing" do
          [ 5, 10 ].each do |quantity|
            price =  logic.unit_price(product, market, organization, order_time, quantity)
            expect(price.sale_price).to eql("2.5".to_d)
          end

          [ 1,2 ].each do |quantity|
            price =  logic.unit_price(product, market, organization, order_time, quantity)
            expect(price.sale_price).to eql(5)
          end

          [ 3,4 ].each do |quantity|
            price =  logic.unit_price(product, market, organization, order_time, quantity)
            expect(price.sale_price).to eql(4)
          end

          [ 0 ].each do |quantity|
            price =  logic.unit_price(product, market, organization, order_time, quantity)
            expect(price.sale_price).to eql("2.5".to_d)  # defaults to first organization-specific price, though that be a little odd?
          end
        end
      end
    end

  end

end
