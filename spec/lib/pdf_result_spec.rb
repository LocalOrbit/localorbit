require 'spec_helper'

describe PdfResult, wip:true do
  subject { described_class.new(pdf_kit) }
  let(:pdf_kit) { double "PdfKit", to_pdf: "the pdf data" }

  it "provides access to the PDF data in a PdfKit object" do
    expect(subject.data).to eq(pdf_kit.to_pdf)
  end
end
