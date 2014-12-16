require "spec_helper"

describe "GenerateInvoicePdf interactor" do
  let!(:order) { create(:order, invoiced_at: 1.day.ago) }

  let(:tempfile) { Tempfile.new("a tempfile") }
  let(:context_double) { double("Context double", 
                                pdf: "The PDF Data", 
                                file: tempfile) }
  let(:pdf_result) { PdfResult.new(data: "The PDF Data") }
  let(:request) { double("Request") }

  let(:pdf_generator) { Invoices::InvoicePdfGenerator }

  it "only generates the pdf once" do
    expect(order.invoice_pdf).to be_nil
    expect(pdf_generator).to receive(:generate_pdf).with(request:request, order:order).once.and_return(pdf_result)

    3.times { GenerateInvoicePdf.perform(request:request, order: order) }
    expect(order.invoice_pdf.file.read).to eq("The PDF Data")
    expect(order.invoice_pdf.name).to eq("#{order.order_number}.pdf")
  end
end
