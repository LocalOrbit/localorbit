require "spec_helper"

describe CartsController do
  let!(:market)   { create(:market, :with_address, :with_delivery_schedule) }
  let!(:delivery) { market.delivery_schedules.first.next_delivery }
  let!(:seller)   { create(:organization, :seller, :single_location, markets: [market]) }
  let!(:product)  { create(:product, :sellable, organization: seller) }

  let!(:buyer)    { create(:organization, :buyer, :single_location, markets: [market]) }
  let!(:user)     { create(:user, organizations: [buyer]) }

  let!(:cart)     { create(:cart, market: market, organization: buyer, delivery: delivery, location: buyer.locations.first, user: user) }

  describe "#update" do
    it "does not error when 0 is entered for a new item" do
      sign_in(user)
      switch_to_subdomain(market.subdomain)

      params = {
        format: 'json',
        product_id: product.id,
        quantity: 0
      }

      request.accept = "application/json"
      put :update, params

      expect(response).to be_success
      expect(cart.reload.items.count).to eql(0)
    end

    it "adds a new item" do
      sign_in(user)
      switch_to_subdomain(market.subdomain)

      params = {
        format: 'json',
        product_id: product.id,
        quantity: 1
      }

      request.accept = "application/json"
      put :update, params

      expect(response).to be_success
      expect(cart.reload.items.count).to eql(1)
    end
  end
end
