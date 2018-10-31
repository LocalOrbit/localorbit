require 'spec_helper'

describe Orders::OrderItems do
  subject { described_class }

  describe '.find_order_items' do
    let!(:market_plan) {create(:plan, :grow) }
    let!(:market_org) { create(:organization, :market, plan: market_plan)}
    let!(:market) { create(:market, organization: market_org) }
    let!(:manager) { create(:user, :market_manager, managed_markets: [market]) }

    let!(:supplier1) { create(:user, :supplier) }
    let!(:supplier1_organization) { create(:organization, :seller, users: [supplier1], markets:[market]) }
    let!(:supplier2) { create(:user, :supplier) }
    let!(:supplier2_organization) { create(:organization, :seller, users: [supplier2], markets:[market]) }

    let!(:buyer1) { create(:user, :buyer) }
    let!(:buyer1_organization) { create(:organization, :buyer, users: [buyer1], markets:[market]) }
    let!(:buyer2) { create(:user, :buyer) }
    let!(:buyer2_organization) { create(:organization, :buyer, users: [buyer2], markets:[market]) }

    let!(:supplier1_product1) { create(:product, :sellable, organization: supplier1_organization) }
    let!(:supplier2_product1) { create(:product, :sellable, organization: supplier2_organization) }

    let!(:order1_item1) { create(:order_item, product: supplier1_product1) }
    let!(:order1) { create(:order, items: [order1_item1], market: market, organization: buyer1_organization) }

    let!(:order2_item1) { create(:order_item, product: supplier2_product1) }
    let!(:order2) { create(:order, items: [order2_item1], market: market, organization: buyer2_organization) }

    let!(:order3_item1) { create(:order_item, product: supplier1_product1) }
    let!(:order3_item2) { create(:order_item, product: supplier2_product1) }
    let!(:order3) { create(:order, items: [order3_item1, order3_item2], market: market, organization: buyer2_organization) }

    context 'logged in as market manager' do
      it "shows all suppliers' order items" do
        items = subject.find_order_items([order1, order2, order3], manager)
        expect(items).to contain_exactly(order1_item1, order2_item1, order3_item1, order3_item2)
      end
    end

    context 'logged in as supplier1' do
      it "shows only supplier1's order items" do
        items = subject.find_order_items([order1, order3], supplier1)
        expect(items).to contain_exactly(order1_item1, order3_item1)
      end
    end
  end
end