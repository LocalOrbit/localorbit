require "spec_helper"

describe "Viewing buyer financials" do
  context "market allows purchase orders" do
    let!(:market)       { create(:market, allow_purchase_orders: true) }

    context "organization not allowed to use purchase orders" do
      let!(:organization) { create(:organization, :buyer, markets: [market], allow_purchase_orders: false) }
      let!(:user)         { create(:user, :buyer, organizations: [organization]) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)

        visit dashboard_path
      end

      it "does not show the financials tab" do
        expect(page).to_not have_link("Financials")
      end
    end

    context "organization is allowed to use purchase orders" do
      let!(:organization) { create(:organization, :buyer, markets: [market], allow_purchase_orders: true) }
      let!(:user)         { create(:user, :buyer, organizations: [organization]) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)

        visit dashboard_path
      end

      it "does show the financials tab" do
        expect(page).to have_link("Financials")
      end
    end
  end

  context "market doesn't allow purchase orders" do
    let!(:market)       { create(:market, allow_purchase_orders: false) }

    context "organization not allowed to use purchase orders" do
      let!(:organization) { create(:organization, :buyer, markets: [market], allow_purchase_orders: false) }
      let!(:user)         { create(:user, :buyer, organizations: [organization]) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)

        visit dashboard_path
      end

      it "does not show the financials tab" do
        expect(page).to_not have_link("Financials")
      end
    end

    context "organization is allowed to use purchase orders" do
      let!(:organization) { create(:organization, :buyer, markets: [market], allow_purchase_orders: true) }
      let!(:user)         { create(:user, :buyer, organizations: [organization]) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)

        visit dashboard_path
      end

      #it "does not show the financials tab" do
      #  expect(page).to_not have_link("Financials")
      #end
    end
  end
end
