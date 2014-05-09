require 'spec_helper'

describe SellerPaymentGroup do
  let!(:market1) { create(:market, po_payment_term: 14) }
  let!(:market_manager) { create :user, managed_markets: [market1] }

  let!(:seller1) { create(:organization, :seller, name: "Better Farms", markets: [market1]) }
  let!(:seller2) { create(:organization, :seller, name: "Great Farms", markets: [market1]) }
  let!(:seller3) { create(:organization, :seller, name: "Betterest Farms", markets: [market1]) }
  let!(:seller4) { create(:organization, :seller, name: "Greater Farms", markets: [market1]) }
  let!(:buyer1)  { create(:organization, :buyer, name: "Money Bags", markets: [market1]) }

  let!(:product1) { create(:product, :sellable, organization: seller1) }
  let!(:product2) { create(:product, :sellable, organization: seller2) }
  let!(:product3) { create(:product, :sellable, organization: seller2) }
  let!(:product4) { create(:product, :sellable, organization: seller3) }

  let!(:order_for_seller_1) { create(:order, items:[create(:order_item, :payable, product: product1, quantity: 4)], market: market1, organization: buyer1, payment_method: "purchase order", order_number: "LO-001", total_cost: 27.96, placed_at: 19.days.ago) }
  let!(:order_for_sellers_2_and_3) { create(:order, items:[create(:order_item, :payable, product: product2, quantity: 3), create(:order_item, :payable, product: product4, quantity: 7)], market: market1, organization: buyer1, payment_method: "purchase order", order_number: "LO-002", total_cost: 69.90, placed_at: 6.days.ago, payment_status: "paid") }
  let!(:order_for_seller_2) { create(:order, items:[create(:order_item, :payable, product: product3, quantity: 6)], market: market1, organization: buyer1, payment_method: "purchase order", order_number: "LO-003", total_cost: 41.94, placed_at: 4.days.ago) }
  let!(:order_for_seller_2_multi_item) { create(:order, items:[create(:order_item, :payable, product: product2, quantity: 9), create(:order_item, :payable, product: product3, quantity: 14)], market: market1, organization: buyer1, payment_method: "purchase order", order_number: "LO-004", total_cost: 160.77, placed_at: 3.days.ago) }
  let!(:order_for_seller_2_multi_item_single_unpayable) { create(:order, items:[create(:order_item, :payable, product: product2, quantity: 9), create(:order_item, product: product3, quantity: 14)], market: market1, organization: buyer1, payment_method: "purchase order", order_number: "LO-005", total_cost: 160.77, placed_at: 3.days.ago) }
  let!(:order_for_seller_2_unpayable) { create(:order, items:[create(:order_item, product: product3, quantity: 14)], market: market1, organization: buyer1, payment_method: "purchase order", order_number: "LO-006", total_cost: 97.86, placed_at: 3.days.ago) }
  let!(:order_for_sellers_2_and_3_unpayable_to_2) { create(:order, items:[create(:order_item, product: product2, quantity: 3), create(:order_item, :payable, product: product4, quantity: 7)], market: market1, organization: buyer1, payment_method: "purchase order", order_number: "LO-007", total_cost: 69.90, placed_at: 6.days.ago, payment_status: "paid") }
  let!(:order_for_seller_2_recent_delivery) { create(:order, items:[create(:order_item, product: product3, quantity: 14, delivery_status: 'delivered')], market: market1, organization: buyer1, payment_method: "purchase order", order_number: "LO-008", total_cost: 97.86, placed_at: 3.days.ago) }
  let!(:order_for_seller_2_and_3_with_recent_delivery_to_2) { create(:order, items:[create(:order_item, product: product3, quantity: 14, delivery_status: 'delivered'), create(:order_item, :payable, product: product4, quantity: 7)], market: market1, organization: buyer1, payment_method: "purchase order", order_number: "LO-009", total_cost: 146.79, placed_at: 3.days.ago) }
  let!(:order_for_seller_2_multi_item_paid) { create(:order, items:[create(:order_item, :payable, product: product2, quantity: 9), create(:order_item, :payable, product: product3, quantity: 14)], market: market1, organization: buyer1, payment_method: "purchase order", order_number: "LO-010", total_cost: 160.77, placed_at: 3.days.ago) }
  let!(:order_for_sellers_2_and_3_with_2_paid) { create(:order, items:[create(:order_item, :payable, product: product2, quantity: 3), create(:order_item, :payable, product: product1, quantity: 7)], market: market1, organization: buyer1, payment_method: "purchase order", order_number: "LO-011", total_cost: 69.90, placed_at: 6.days.ago, payment_status: "paid") }
  let!(:order_for_seller_2_buyer_and_seller_paid) { create(:order, items:[create(:order_item, :payable, product: product3, quantity: 6)], market: market1, organization: buyer1, payment_method: "credit card", order_number: "LO-012", total_cost: 41.94, placed_at: 4.days.ago, payment_status: "paid") }

  let!(:payments_for_order_for_seller_2_multi_item_paid) { create(:payment, payee: seller2, orders: [order_for_seller_2_multi_item_paid], amount: 160.77) }
  let!(:payments_for_order_for_sellers_2_and_3_with_2_paid) { create(:payment, payee: seller2, orders: [order_for_sellers_2_and_3_with_2_paid], amount: 20.97) }

  let!(:buyer_payment_for_order_for_sellers_2_both_paid) { create(:payment, payee: nil, orders: [order_for_seller_2_buyer_and_seller_paid], payment_type: "credit card", amount: 20.97, status: "paid") }
  let!(:seller_payments_for_order_for_sellers_2_both_paid) { create(:payment, payee: seller2, orders: [order_for_seller_2_buyer_and_seller_paid], amount: 20.97) }

  describe '.for_user' do
    it 'contains the right set of order information' do
      sellers = SellerPaymentGroup.for_user(market_manager)

      # only 3 sellers are payable
      expect(sellers.size).to eq(3)

      # sellers are ordered by name
      expect(sellers.map(&:name)).to eq(["Better Farms", "Betterest Farms", "Great Farms"])

      seller = sellers[0]
      # Better Farms is payable for:
      expect(seller.orders.map(&:order_number)).to eq(["LO-001", "LO-011"])
      expect(seller.owed).to eq(76.89)

      seller = sellers[1]
      # Betterest Farms is payable for:
      expect(seller.orders.map(&:order_number)).to eq(["LO-002", "LO-007", "LO-009"])
      expect(seller.owed).to eq(146.79)

      seller = sellers[2]
      # Great Farms is payable for:
      expect(seller.orders.map(&:order_number)).to eq(["LO-002", "LO-003", "LO-004"])
      expect(seller.owed).to eq(223.68)
    end

    describe 'for multi market manager' do
      let!(:market2) { create(:market, po_payment_term: 14, managers: [market_manager]) }

      let!(:seller2) { create(:organization, :seller, name: "Great Farms", markets: [market1, market2]) }

      let!(:order_for_seller_2_multi_item) { create(:order, items:[create(:order_item, :payable, product: product2, quantity: 9), create(:order_item, :payable, product: product3, quantity: 14)], market: market2, organization: buyer1, payment_method: "purchase order", order_number: "LO-004", total_cost: 160.77, placed_at: 3.days.ago) }

      it 'contains the right set of order information' do
        sellers = SellerPaymentGroup.for_user(market_manager.reload)

        # only 4 sellers are payable
        expect(sellers.size).to eq(4)

        # sellers are ordered by name
        expect(sellers.map(&:name)).to eq(["Better Farms", "Betterest Farms", "Great Farms", "Great Farms"])

        seller = sellers[0]
        # Better Farms is payable for:
        expect(seller.orders.map(&:order_number)).to eq(["LO-001", "LO-011"])
        expect(seller.owed).to eq(76.89)

        seller = sellers[1]
        # Betterest Farms is payable for:
        expect(seller.orders.map(&:order_number)).to eq(["LO-002", "LO-007", "LO-009"])
        expect(seller.owed).to eq(146.79)

        seller = sellers[2]
        # Great Farms in market 1 is payable for:
        expect(seller.orders.map(&:order_number)).to eq(["LO-002", "LO-003"])
        expect(seller.owed).to eq(62.91)

        seller = sellers[3]
        # Great Farms in market 2 is payable for:
        expect(seller.orders.map(&:order_number)).to eq(["LO-004"])
        expect(seller.owed).to eq(160.77)
      end
    end
  end
end
