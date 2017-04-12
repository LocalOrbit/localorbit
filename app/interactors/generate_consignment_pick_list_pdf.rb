class GenerateConsignmentPickListPdf
  include Interactor

  def perform
    if context[:orders].present?
      pdf_result = ConsignmentPickLists::ConsignmentPickListPdfGenerator.generate_pdf(request: request, orders: orders)
      printable.pdf = pdf_result.data
      printable.pdf.name = "picklist.pdf"
      printable.save!
    end
  end
end
