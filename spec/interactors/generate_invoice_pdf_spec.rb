require "spec_helper"

describe "GenerateInvoicePdf interactor" do
  let!(:order) { create(:order, invoiced_at: 1.day.ago) }

  let(:tempfile) { Tempfile.new("a tempfile") }
  let(:context_double) { double("Context double", 
                                pdf: "The PDF Data", 
                                file: tempfile) }
  let(:request) { double("Request") }

  it "only generates the pdf once" do
    expect(order.invoice_pdf).to be_nil
    expect(MakeInvoicePdfTempFile).to receive(:perform).with(request:request, order:order).once.and_return(context_double)

    3.times { GenerateInvoicePdf.perform(request:request, order: order) }
    expect(order.invoice_pdf.file.read).to eq("The PDF Data")
    expect(order.invoice_pdf.name).to eq("#{order.order_number}.pdf")
  end
end
