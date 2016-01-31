require "spec_helper"
require 'csv'

describe "Export Products CSV"  do
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
    end

    it "export ALL products to CSV" do
      visit admin_products_path
      rows = download_products_csv

      products = user.managed_products.preload(:prices,:lots,:organization).order('organizations.name asc')
      see_products_in_csv products: products.decorate, rows: rows
    end

    it "export products for a selected Market" do
      visit admin_products_path(q:{markets_id_in: market2.id, s: 'name asc'})
      rows = download_products_csv

      products = user.managed_products.preload(:prices,:lots,:organization).order('name asc').search({markets_id_in: market2.id}).result
      expect(products.count).to eq(2) # should only be 2 results when filtered down
      see_products_in_csv products: products.decorate, rows: rows
    end

    it "export products for a selected Organization" do
      visit admin_products_path(q:{organization_id_in:org1.id})
      rows = download_products_csv
      products = user.managed_products.preload(:prices,:lots,:organization).order('name asc').search({organization_id_in: org1.id}).result
      expect(products.count).to eq(1) 
      see_products_in_csv products: products.decorate, rows: rows
    end

    it "apply sorting to the export" do
      # Sort name descending:
      visit admin_products_path(q:{markets_id_in: market1.id, s: 'name desc'})
      rows = download_products_csv
      products = user.managed_products.preload(:prices,:lots,:organization).order('name desc').search({markets_id_in: market1.id}).result
      expect(products.count).to eq(2) # should only be 2 results when filtered down
      see_products_in_csv products: products.decorate, rows: rows

      # Sort name ascending:
      visit admin_products_path(q:{markets_id_in: market1.id, s: 'name asc'})
      rows = download_products_csv
      products = user.managed_products.preload(:prices,:lots,:organization).order('name asc').search({markets_id_in: market1.id}).result
      expect(products.count).to eq(2) # should only be 2 results when filtered down
      see_products_in_csv products: products.decorate, rows: rows
    end
  end

  #
  # HELPERS
  # 
  def download_products_csv
    click_link "Export CSV"
    expect(page.response_headers["Content-Disposition"]).to eq('attachment; filename="products.csv"')
    rows = CSV.parse(page.body)
    header_row = rows.shift
    expect(header_row).to eq(%w{Supplier Market Name Pricing Available Code})
    rows
  end

  def see_products_in_csv(products:, rows:)
    expect(products).to be
    expect(rows).to be
    expect(rows.count).to eq(products.count)

    products.zip(rows).each.with_index do |(product,row),i|
      compare_product_to_csv_row product, row, i
    end
  end

  def compare_product_to_csv_row(product,row, i)
    prefix = "Product CSV row #{i}"
    seller,market,name,pricing,available = row

    compare_product_val_to_csv_cell(i, "Supplier", seller, product.organization_name)
    compare_product_val_to_csv_cell(i, "Market", market, product.market_name)
    compare_product_val_to_csv_cell(i, "Name", name, product.name_and_unit)
    compare_product_val_to_csv_cell(i, "Pricing", pricing, product.prices.view_sorted.decorate.map(&:quick_info).join(", "))
    compare_product_val_to_csv_cell(i, "Available", available, product.available_inventory.to_s)
  end

  def compare_product_val_to_csv_cell(i, field_name, actual, expected)
    expect(actual).to eq(expected), "Product CSV row #{i}: expected #{field_name} #{expected.inspect} but got #{actual.inspect}"
  end
end

__END__
    context "by market" do
      it "shows an empty state" do
        select empty_market.name, from: "filter_market"

        expect(page).to have_content("No Result")
      end

      it "shows all products when unfiltered" do
        expect(page).to have_content(org1_product.name)
        expect(page).to have_content(org2_product.name)
        expect(page).to have_content(org3_product.name)
        expect(page).to have_content(org4_product.name)
      end

      it "shows products for only the selected market" do
        select market1.name, from: "filter_market"

        expect(page).to have_content(org1_product.name)
        expect(page).to have_content(org2_product.name)
        expect(page).to_not have_content(org3_product.name)
        expect(page).to_not have_content(org4_product.name)
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
        select org1.name, from: "filter_organization"

        expect(page).to have_content(org1_product.name)

        expect(page).to_not have_content(org2_product.name)
        expect(page).to_not have_content(org3_product.name)
        expect(page).to_not have_content(org4_product.name)
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
      it "shows an empty state" do
        select empty_market.name, from: "filter_market"

        expect(page).to have_content("No Result")
      end

      it "shows all products when unfiltered" do
        expect(page).to have_content(org1_product.name)
        expect(page).to have_content(org2_product.name)
        expect(page).to have_content(org3_product.name)
        expect(page).to have_content(org4_product.name)
      end

      it "shows products for only the selected market" do
        select market1.name, from: "filter_market"

        expect(page).to have_content(org1_product.name)
        expect(page).to have_content(org2_product.name)

        expect(page).to_not have_content(org3_product.name)
        expect(page).to_not have_content(org4_product.name)
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
        select org1.name, from: "filter_organization"

        expect(page).to have_content(org1_product.name)

        expect(page).to_not have_content(org2_product.name)
        expect(page).to_not have_content(org3_product.name)
        expect(page).to_not have_content(org4_product.name)
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
        select org1.name, from: "filter_organization"

        expect(page).to have_content(org1_product.name)

        expect(page).to_not have_content(org2_product.name)
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
        select org1.name, from: "filter_organization"

        expect(page).to have_content(org1_product.name)

        expect(page).to_not have_content(org2_product.name)
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
