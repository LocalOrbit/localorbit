class GenerateConsignmentPickListPdf
  include Interactor

  def perform
    if context[:orders].present?
      pdf_result = ConsignmentPickLists::ConsignmentPickListPdfGenerator.generate_pdf(request: request, orders: orders)
      context[:picklist_pdf] = pdf_result.data
    end
  end
end
