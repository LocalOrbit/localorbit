require "spec_helper"

describe GenerateTableTentsOrPosters do
  include_context "the mini market"

  let(:request) {double("request", {:base_url=>"http://www.example.com"})}
  let(:order) {create(:order, organization: buyer_organization)}
  let(:zaphod_farms) {create(:organization, :seller, :single_location, name: "Zaphod")}
  let(:prefect_farms) {create(:organization, :seller, :single_location, name: "Prefect")}
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
        { farm: prefect_farms },
        { farm: zaphod_farms }
      )
    end

    it "creates an array of sellers and item names if include_product_names is true" do
      items_for_printing = GenerateTableTentsOrPosters.get_page_list(order: order.reload, include_product_names: true)
      expect(items_for_printing).to contain_exactly(
        { farm: zaphod_farms, product_name: product1.name },
        { farm: zaphod_farms, product_name: product2.name },
        { farm: prefect_farms, product_name: product3.name }
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

  describe "#build_seller_map", :wip=>true do
    it "gets a map from the seller's shipping location" do
      p GenerateTableTentsOrPosters.build_seller_map(zaphod_farms)
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
                       include_product_names: false}).
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
                      include_product_names: false}).
        and_return(double "context", pdf_result: "ThePdf")

      context = GenerateTableTentsOrPosters.perform(order: order, type: "table tents", include_product_names: false, request: request)
      expect(context.pdf_result).to eq "ThePdf"
    end
  end
end
