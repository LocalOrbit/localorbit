require "spec_helper"

describe "Filter products", :js do
  let!(:empty_market) { create(:market) }
  let!(:market1)      { create(:market) }
  let!(:org1)         { create(:organization, :seller, markets: [market1]) }
  let!(:org1_product) { create(:product, :sellable, organization: org1) }
  let!(:org2)         { create(:organization, :seller, markets: [market1]) }
  let!(:org2_product) { create(:product, :sellable, organization: org2) }

  let!(:market2)      { create(:market) }
  let!(:org3)         { create(:organization, :seller, markets: [market2]) }
  let!(:org3_product) { create(:product, :sellable, organization: org3) }
  let!(:org4)         { create(:organization, :seller, markets: [market2]) }
  let!(:org4_product) { create(:product, :sellable, organization: org4) }
  let!(:org5)         { create(:organization, :buyer, markets: [market2]) }

  context "as admin" do
    let!(:user) { create(:user, role: "admin") }

    before do
      sign_in_as(user)
      visit admin_products_path
    end

    context "by market" do

      it "shows all products when unfiltered" do
        expect(page).to have_content(org1_product.name)
        expect(page).to have_content(org2_product.name)
        expect(page).to have_content(org3_product.name)
        expect(page).to have_content(org4_product.name)
      end

      it "shows products for only the selected market" do
        select market1.name, from: "filter_market", visible: false

        expect(page).to have_content(org1_product.name)
        expect(page).to have_content(org2_product.name)
        expect(page).to_not have_content(org3_product.name)
        expect(page).to_not have_content(org4_product.name)

        unselect market1.name, from: "filter_market", visible: false

      end
    end

    context "by organization" do
      it "only show sellers for filtering" do
        expect(page).to_not have_select("filter_organization", with_options: [org5.name])
      end

      it "shows all products when unfiltered" do
        expect(page).to have_content(org1_product.name)
        expect(page).to have_content(org2_product.name)
        expect(page).to have_content(org3_product.name)
        expect(page).to have_content(org4_product.name)
      end

      it "shows products for only the selected organization" do
        select org1.name, from: "filter_organization", visible: false

        expect(page).to have_content(org1_product.name)

        expect(page).to_not have_content(org2_product.name)
        expect(page).to_not have_content(org3_product.name)
        expect(page).to_not have_content(org4_product.name)

        unselect org1.name, from: "filter_organization", visible: false

      end
    end
  end

  context "as multi-market manager" do
    let!(:user) { create(:user, role: "user", managed_markets: [market1, market2, empty_market]) }

    before do
      switch_to_subdomain(market1.subdomain)
      sign_in_as(user)
      visit admin_products_path
    end

    context "by market" do
      it "shows all products when unfiltered" do
        expect(page).to have_content(org1_product.name)
        expect(page).to have_content(org2_product.name)
        expect(page).to have_content(org3_product.name)
        expect(page).to have_content(org4_product.name)
      end

      it "shows products for only the selected market" do
        select market1.name, from: "filter_market", visible: false

        expect(page).to have_content(org1_product.name)
        expect(page).to have_content(org2_product.name)

        expect(page).to_not have_content(org3_product.name)
        expect(page).to_not have_content(org4_product.name)

        unselect market1.name, from: "filter_market", visible: false

      end
    end

    context "by organization" do
      it "shows all products when unfiltered" do
        expect(page).to have_content(org1_product.name)
        expect(page).to have_content(org2_product.name)
        expect(page).to have_content(org3_product.name)
        expect(page).to have_content(org4_product.name)
      end

      it "shows products for only the selected organization" do
        select org1.name, from: "filter_organization", visible: false

        expect(page).to have_content(org1_product.name)

        expect(page).to_not have_content(org2_product.name)
        expect(page).to_not have_content(org3_product.name)
        expect(page).to_not have_content(org4_product.name)

        unselect org1.name, from: "filter_organization", visible: false

      end
    end
  end

  context "as single market manager" do
    let!(:user) { create(:user, managed_markets: [market1]) }

    before do
      switch_to_subdomain(market1.subdomain)
      sign_in_as(user)

      visit admin_products_path
    end

    context "by market" do
      it "does not show a market filter dropdown" do
        expect(page).to_not have_field("filter_market")
      end
    end

    context "by organization" do
      it "shows all products when unfiltered" do
        expect(page).to have_content(org1_product.name)
        expect(page).to have_content(org2_product.name)
      end

      it "shows products for only the selected organization" do
        select org1.name, from: "filter_organization", visible: false

        expect(page).to have_content(org1_product.name)

        expect(page).to_not have_content(org2_product.name)

        unselect org1.name, from: "filter_organization", visible: false

      end
    end
  end

  context "as user in multiple organizations" do
    let!(:user) { create(:user) }

    before do
      user.organizations << org1
      user.organizations << org2

      switch_to_subdomain(market1.subdomain)
      sign_in_as(user)
      visit admin_products_path
    end

    context "by market" do
      it "does not show a market filter dropdown" do
        expect(page).to_not have_field("filter_market")
      end
    end

    context "by organization" do
      it "shows all products when unfiltered" do
        expect(page).to have_content(org1_product.name)
        expect(page).to have_content(org2_product.name)
      end

      it "shows products for only the selected organization" do
        select org1.name, from: "filter_organization", visible: false

        expect(page).to have_content(org1_product.name)

        expect(page).to_not have_content(org2_product.name)

        unselect org1.name, from: "filter_organization", visible: false

      end
    end
  end

  context "as user in a single organizations" do
    let!(:user) { create(:user) }

    before do
      user.organizations << org1

      switch_to_subdomain(market1.subdomain)
      sign_in_as(user)
      visit admin_products_path
    end

    context "by market" do
      it "does not show a market filter dropdown" do
        expect(page).to_not have_field("filter_market")
      end
    end

    context "by organization" do
      it "does not show a organization filter dropdown" do
        expect(page).to_not have_field("filter_organization")
      end
    end
  end
end
