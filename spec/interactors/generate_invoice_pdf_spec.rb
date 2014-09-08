require "spec_helper"

describe "GenerateInvoicePdf interactor" do
  let!(:order) { create(:order, invoiced_at: 1.day.ago) }

  it "only generates the pdf once" do
    expect(order.invoice_pdf).to be_nil
    expect(PDFKit).to receive(:new).once.and_return(double("PDFKit double", to_file: "/tmp/test-invoice.pdf"))

    4.times { GenerateInvoicePdf.perform(order: order) }

    expect(order.invoice_pdf.file.first).to eql("/tmp/test-invoice.pdf")
  end
end
