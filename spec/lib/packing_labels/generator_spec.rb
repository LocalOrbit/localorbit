module PackingLabels
  describe Generator do
    subject { described_class }

    context "#perform interaction testing" do
      let(:request)     { double :request, base_url: base_url }
      let(:base_url)    { "the base url" }
      let(:delivery)    { double "Delivery"  }
      let(:order_infos) { double "A list of order infos"  }
      let(:labels)      { double "A list of labels"  }
      let(:pages)       { double "A list of pages"  }
      let(:pdf_context) { double "A PDF context", pdf_result: "the pdf result" }

      it "works by creating order infos, labels, and then pages REPRISE" do
        expect(PackingLabels::OrderInfo).to receive(:make_order_infos).with(delivery,host:base_url).and_return(order_infos)
        expect(PackingLabels::Label).to receive(:make_labels).with(order_infos).and_return(labels)
        expect(PackingLabels::Page).to receive(:make_pages).with(labels).and_return(pages)

        expect(GeneratePdf).to receive(:perform).with(
          request: request,
          template: "avery_labels/labels",
          pdf_size: { page_size: "letter" },
          params: { pages: pages }
        ).and_return(pdf_context)

        pdf_result = subject.generate(delivery: delivery, request: request)

        expect(pdf_result).to eq("the pdf result")
      end
    end
  end
end
