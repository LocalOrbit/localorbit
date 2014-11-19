describe HtmlToPdfConverter, :pdf do
  subject { described_class }

  let(:pdf_settings) { { page_size: "letter" }.merge(TemplatedPdfGenerator::ZeroMargins) }
  let(:html) { "<h1>Hi there</h1>" }

  it "creates a PdfResult containing PDF data" do
    pdf_result = subject.generate_pdf(html: html, pdf_settings: pdf_settings)
    expect(pdf_result).to be
    expect(pdf_result.data).to be
    expect(pdf_result.data).to match(/^%PDF-1.4/)
    expect(pdf_result.path).to be_nil
  end

  context "when a path is provided" do
    let(:tempfile) { Tempfile.new("pdftest") }
    let(:path) { tempfile.path }


    it "creates a PdfResult containing a File object refering to thePDF data" do
      pdf_result = subject.generate_pdf(html: html, pdf_settings: pdf_settings, path: path)
      expect(pdf_result).to be
      expect(pdf_result.data).to be
      expect(pdf_result.data.index("%PDF-1.4")).to eq(0)
      expect(pdf_result.path).to eq(path)

      expect(File.read(path)).to eq(pdf_result.data)
    end

    after do
      tempfile.close
      tempfile.unlink
    end
  end

end
