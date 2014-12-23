class HtmlToPdfConverter
  class << self
    def generate_pdf(html:, pdf_settings:, path:nil)
      pdf_kit = PDFKit.new(html, pdf_settings)
      PdfResult.new(
        data: pdf_kit.to_pdf(path),
        path: path
      )
    end
  end
end
