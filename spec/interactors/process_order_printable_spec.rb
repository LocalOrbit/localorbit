require "spec_helper"

describe ProcessOrderPrintable do
  subject { described_class }

  let(:order_printable_atts) { 
    {printable_type: "Arcturian Mega Donkey",
     include_product_names: true}
  }
  let(:order_printable) { create(:order_printable, order_printable_atts) }
  let(:order_printable_id) { order_printable.id }

  let(:context) { double("result context", 
                         pdf_result: double("Pdf result", data: "the pdf data")
                        )}
  let(:request) { double "a request" }

  def expect_generate_table_tents_or_posters
    expect(GenerateTableTentsOrPosters).to receive(:perform).
      with(order: order_printable.order,
           type: order_printable.printable_type,
           include_product_names: order_printable.include_product_names,
           request: request).
      and_return(context)
  end

  it "loads an OrderPrintable and generates the corresponding PDF document, stores that PDF as an attachment" do
    expect_generate_table_tents_or_posters

    subject.perform(order_printable_id: order_printable_id, request: request)

    updated_order_printable = OrderPrintable.find(order_printable_id)
    expect(updated_order_printable.pdf.file.read).to eq("the pdf data")
    expect(updated_order_printable.pdf.name).to eq("Arcturian_Mega_Donkey.pdf")
  end

  it "heeds the include_product_names flag" do
    order_printable_atts[:include_product_names] = false # the prior test used true
    expect_generate_table_tents_or_posters
    subject.perform(order_printable_id: order_printable_id, request: request)
  end


end
