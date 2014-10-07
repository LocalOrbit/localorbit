require "spec_helper"

describe "GenerateInvoicePdf interactor" do
  let!(:order) { create(:order, invoiced_at: 1.day.ago) }

  let(:tempfile) { Tempfile.new("a tempfile") }
  let(:context_double) { double("Context double", pdf: "The PDF Data", file: tempfile) }

  it "only generates the pdf once" do
    expect(order.invoice_pdf).to be_nil
    expect(MakeInvoicePdfTempFile).to receive(:perform).with(order:order).once.and_return(context_double)

    3.times { GenerateInvoicePdf.perform(order: order) }
    expect(order.invoice_pdf.file.read).to eq("The PDF Data")
  end
end
