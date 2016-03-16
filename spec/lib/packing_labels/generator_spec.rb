require 'spec_helper'

module PackingLabels
  describe Generator do
    subject { described_class }

    context "#perform interaction testing" do
      let(:request)     { double :request, base_url: base_url }
      let(:base_url)    { "the base url" }
      let(:orders)      { "some orders"  }
      let(:order_infos) { double "A list of order infos"  }
      let(:labels)      { double "A list of labels"  }
      let(:pages)       {[:a=>{:template=>"avery_labels/vertical_product_1", :data=>{:order=>{:id=>20159, :deliver_on=>"March  3, 2016", :order_number=>"LO-16-SPRINGFIELD-0000020", :buyer_name=>"Bistro LeBeau", :market_logo_url=>"/media/W1siZiIsIjIwMTQvMDUvMDcvMDgvMzQvMjAvNjc5L2xvZ29fbGFyZ2UuanBnIl1d?sha=ac02f564a982c800", :zpl_logo=>"", :qr_code_url=>"http://chart.apis.google.com/chart?cht=qr&chs=300x300&chl=http%3A%2F%2Fapp.localtest.me%3A3000%2Fo%2F20159&chld=H|0"}, :product=>{:product_name=>"Flounder, Summer", :unit_desc=>"Pound", :quantity=>2, :lot_desc=>"Lot #446", :producer_name=>"Local Ocean", :product_code=>nil}}}]}
      let(:pdf_result)  { "the pdf result" }
      let(:zpl_result)  { "the zpl result" }
      let(:product_labels_only) { true }
      let(:product_label_format) { 4 }
      let(:print_multiple_labels_per_item) { false }

      it "works by creating order infos, labels, and then pages" do
        expect(PackingLabels::OrderInfo).to receive(:make_order_infos).with(orders:orders,host:base_url).and_return(order_infos)
        expect(PackingLabels::Label).to receive(:make_labels).with(order_infos, product_labels_only, product_label_format, print_multiple_labels_per_item).and_return(labels)
        expect(PackingLabels::Page).to receive(:make_pages).with(labels, product_label_format).and_return(pages)

        expect(TemplatedPdfGenerator).to receive(:generate_pdf).with(
          request: request,
          template: "avery_labels/labels_4",
          pdf_settings: TemplatedPdfGenerator::ZeroMargins.merge({ page_size: "letter" }),
          locals: {
            params: { pages: pages }
          }
        ).and_return(pdf_result)

        pdf_result = subject.generate(orders: orders, request: request, product_labels_only: product_labels_only, product_label_format: product_label_format, print_multiple_labels_per_item: print_multiple_labels_per_item) # from HEAD

        expect(pdf_result).to eq("the pdf result")
      end

      context "1-up" do
        let(:product_label_format) { 1 }

        VCR.use_cassette('labelary', :record => :none) do

          it "works by creating order infos, labels, and then pages for zpl (zebra)", :vcr do
          expect(PackingLabels::OrderInfo).to receive(:make_order_infos).with(orders:orders,host:base_url).and_return(order_infos)
          expect(PackingLabels::Label).to receive(:make_labels).with(order_infos, product_labels_only, product_label_format, print_multiple_labels_per_item).and_return(labels)
          expect(PackingLabels::Page).to receive(:make_pages).with(labels, product_label_format).and_return(pages)

          zpl_result = subject.generate(orders: orders, request: request, product_labels_only: product_labels_only, product_label_format: product_label_format, print_multiple_labels_per_item: print_multiple_labels_per_item) # from HEAD
          expect(zpl_result[0][0]).to include("^XA^FX")

          end
        end
      end
    end
  end
end
