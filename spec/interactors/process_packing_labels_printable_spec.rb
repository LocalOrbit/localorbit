require "spec_helper"

describe ProcessPackingLabelsPrintable do
  subject { described_class }

  let(:packing_labels_printable) { create(:packing_labels_printable) }
  let(:packing_labels_printable_id) { packing_labels_printable.id }
  let(:delivery) { packing_labels_printable.delivery }
  let!(:order1) { create(:order, delivery: delivery) }
  let!(:order2) { create(:order, delivery: delivery) }
  let(:orders) { [order1,order2].sort_by(&:id) }

  let(:context) { double("result context",
                         pdf_result: double("Pdf result", data: "the pdf data")
                        )}
  let(:request) { double "a request" }
  let(:pdf_result) {double("Pdf result", data: "the pdf data")}

  def expect_generate_packing_labels_for_orders(orders)
    expect(PackingLabels::Generator).to receive(:generate).
      with(orders:orders,
           request: request).
      and_return(pdf_result)
  end

  it "loads an PackingLabelsPrintable and generates the corresponding PDF document, stores that PDF as an attachment" do
    expect_generate_packing_labels_for_orders(orders)

    subject.perform(packing_labels_printable_id: packing_labels_printable_id, request: request)

    updated_packing_labels_printable = PackingLabelsPrintable.find(packing_labels_printable_id)
    expect(updated_packing_labels_printable.pdf.file.read).to eq("the pdf data")
    expect(updated_packing_labels_printable.pdf.name).to eq("delivery_labels.pdf")
  end
end
