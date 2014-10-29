require "spec_helper"

describe GenerateTableTentsOrPosters do
  include_context "the mini market"

  let(:request) {double("request", {:base_url=>"http://www.example.com"})}
  let(:order) {create(:order, organization: buyer_organization)}
  let(:zaphod_farms) {create(:organization, :seller, name: "Zaphod")}
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
      expect(items_for_printing.size).to eq 2
      expect(items_for_printing.first[:farm][:id]).to eq prefect_farms.id
    end

    it "creates an array of sellers and item names if include_product_names is true" do
      items_for_printing = GenerateTableTentsOrPosters.get_page_list(order: order.reload, include_product_names: true)
      expect(items_for_printing.size).to eq 3
      expect(items_for_printing.first[:farm][:id]).to eq prefect_farms.id
      expect(items_for_printing.first[:product_name]).to eq product3.name
    end
  end

  describe "#perform"  do
    it "creates a pdf" do
      context = GenerateTableTentsOrPosters.perform(order: order, type: "poster", include_product_names: false, request: request)
      expect(context.pdf.match(/^%PDF-1.4/)).to_not eq nil
    end
  end
end