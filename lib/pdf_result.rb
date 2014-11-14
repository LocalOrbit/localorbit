class PdfResult
  attr_reader :data

  def initialize(pdf_kit)
    @data = pdf_kit.to_pdf
  end
end