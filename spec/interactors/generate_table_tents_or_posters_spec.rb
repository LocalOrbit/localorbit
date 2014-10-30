require "spec_helper"

describe GenerateTableTentsOrPosters do
  include_context "the mini market"

  let(:request) {double("request", {:base_url=>"http://www.example.com"})}
  let(:order) {create(:order, organization: buyer_organization)}
  let(:zaphod_farms) {create(:organization, :seller, :single_location, name: "Zaphod")}
  let(:prefect_farms) {create(:organization, :seller, name: "Prefect")}
  let(:product1) {create :product, :sellable, organization: zaphod_farms}
  let(:product2) {create :product, :sellable, organization: zaphod_farms}
  let(:product3) {create :product, :sellable, organization: prefect_farms}
  let!(:order_item1) {create :order_item, order: order, product: product1}
  let!(:order_item2) {create :order_item, order: order, product: product2}
  let!(:order_item3) {create :order_item, order: order, product: product3}

  describe "#get_page_list" do
    it "creates an array of sellers for an order if include_product_names is false" do
      items_for_printing = GenerateTableTentsOrPosters.get_page_list(order: order.reload, include_product_names: false)
      expect(items_for_printing).to contain_exactly(
        { farm: prefect_farms, farm_map: GenerateTableTentsOrPosters.build_seller_map(prefect_farms) },
        { farm: zaphod_farms, farm_map: GenerateTableTentsOrPosters.build_seller_map(zaphod_farms) }
      )
    end

    it "creates an array of sellers and item names if include_product_names is true" do
      items_for_printing = GenerateTableTentsOrPosters.get_page_list(order: order.reload, include_product_names: true)
      expect(items_for_printing).to contain_exactly(
        { farm: zaphod_farms, product_name: product1.name, farm_map: GenerateTableTentsOrPosters.build_seller_map(zaphod_farms)},
        { farm: zaphod_farms, product_name: product2.name, farm_map: GenerateTableTentsOrPosters.build_seller_map(zaphod_farms) },
        { farm: prefect_farms, product_name: product3.name, farm_map: GenerateTableTentsOrPosters.build_seller_map(prefect_farms) }
      )
    end
  end

  describe "#get_template_from_type" do
    it "gets from the type" do
      expect(GenerateTableTentsOrPosters.get_template_from_type(type: "poster")).to eq "table_tents_and_posters/poster"
      expect(GenerateTableTentsOrPosters.get_template_from_type(type: "table tents")).to eq "table_tents_and_posters/table_tent"
    end
  end

  describe "#get_pdf_size" do
    it "gets from the type" do
      expect(GenerateTableTentsOrPosters.get_pdf_size(type: "poster")).to eq({page_size: "letter"})
      expect(GenerateTableTentsOrPosters.get_pdf_size(type: "table tents")).to eq({page_width: 101.6, page_height: 152.4})
    end
  end

  describe "#build_seller_map" do
    it "gets a map from the seller's shipping location" do
      expect(GenerateTableTentsOrPosters.build_seller_map(zaphod_farms).match(/mapbox/)).to_not eq nil
      expect(GenerateTableTentsOrPosters.build_seller_map(prefect_farms)).to eq ""
    end
  end

  describe ".product_category_name" do
    # IDs of categories in production at level 2 who should prefer their parent (level 1) category names:
    let(:special_cat_ids) { [312, 1269, 397, 498, 504, 228, 248, 276, 1275] } 
    # (omitted "2" because in dev/test it's Fruits which is a) confusing as heck for this test and b) Specialty in Production.  We'll trust the remaining items will be good to test.)

    let(:special_cats) {
      special_cat_ids.map do |cat_id| 
        if existing = Category.where(id:cat_id).first 
          existing.destroy # go away for this test, we want our own categories in these slots:
        end
        create(:category, parent: l1_fruits)
      end
    }

    let(:l1_fruits) { Category.find_by_name("Fruits") }
    let(:l1_vegetables) { Category.find_by_name("Vegetables") }
    let(:l1_beverages) { Category.find_by_name("Beverages") }

    let(:l2_broc_caul_cabbage) { l3_cabbage.parent }
    let(:l2_citris) { Category.find_by_name("Citris") }

    let(:l3_cabbage) { Category.find_by_name("Cabbage") }

    let(:l4_oranges) { Category.find_by_name("Navel Oranges") }

    let(:l1_prod) { create(:product, name: "L1 Prod", category: l1_beverages) }
    let(:l2_prod) { create(:product, name: "L2 Prod", category: l2_broc_caul_cabbage) }
    let(:l3_prod) { create(:product, name: "L3 Prod", category: l3_cabbage) }
    let(:l4_prod) { create(:product, name: "L4 Prod", category: l4_oranges) }

    def product_category_name(product)
      GenerateTableTentsOrPosters.product_category_name(product)
    end

    context "products in Category level 2" do
      it "returns the name of their level 2 Category" do
        expect(product_category_name(l2_prod)).to eq(l2_broc_caul_cabbage)
      end
    end
    context "products in Category level 3" do
      it "returns the name of their level 2 Category" 
    end
    context "products in Category level 4" do
      it "returns the name of the level 2 Category" 
    end

    context "products in Category level 1 (unrealistic)" do
      it "returns the name of their level 1 Category"
    end

    context "products with missing Category (unrealistic)" do
      it "returns ?"
    end

    context "products with level 3 category with missing parent (unrealistic)" do
      it "returns ?"
    end
  end

  describe "#perform"  do
    it "creates a pdf" do
      context = GenerateTableTentsOrPosters.perform(order: order, type: "poster", include_product_names: false, request: request)
      expect(context.pdf_result.data.match(/^%PDF-1.4/)).to_not eq nil
    end

    it "sends the correct poster parameters to GeneratePdf" do
      expect(GeneratePdf).to receive(:perform).
        with(request: request,
             template: "table_tents_and_posters/poster",
             pdf_size: {page_size: "letter"},
             params: { page_list: GenerateTableTentsOrPosters.get_page_list(order: order.reload, include_product_names: false),
                       include_product_names: false,
                       market: order.market}).
        and_return(double "context", pdf_result: "ThePdf")

      context = GenerateTableTentsOrPosters.perform(order: order, type: "poster", include_product_names: false, request: request)
      expect(context.pdf_result).to eq "ThePdf"
    end

    it "sends the correct table tent parameters to GeneratePdf" do
      expect(GeneratePdf).to receive(:perform).
        with(request: request,
             template: "table_tents_and_posters/table_tent",
             pdf_size: {page_width: 101.6, page_height: 152.4},
             params: {page_list: GenerateTableTentsOrPosters.get_page_list(order: order.reload, include_product_names: false),
                      include_product_names: false,
                      market: order.market}).
        and_return(double "context", pdf_result: "ThePdf")

      context = GenerateTableTentsOrPosters.perform(order: order, type: "table tents", include_product_names: false, request: request)
      expect(context.pdf_result).to eq "ThePdf"
    end
  end
end
