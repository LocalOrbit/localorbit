class GenerateConsignmentPrintablePdf
  include Interactor

  def perform
    if context[:orders].present?

      printable_tempfiles = []

      orders.each do |order|
        tempfile = Tempfile.new("tmp-#{type}-#{order.order_number}")
        case type
          when "receipt"
            pdf_result = ConsignmentReceipts::ConsignmentReceiptPdfGenerator.generate_pdf(request: request, order: order, path: tempfile.path)

          when "pick_list"
            pdf_result = ConsignmentPickLists::ConsignmentPickListPdfGenerator.generate_pdf(request: request, order: order, path: tempfile.path)

          when "invoice"
            pdf_result = ConsignmentInvoices::ConsignmentInvoicePdfGenerator.generate_pdf(request: request, order: order, path: tempfile.path)

          else
            nil
        end
        printable_tempfiles << tempfile
      end
      merged_pdf = GhostscriptWrapper.merge_pdf_files(printable_tempfiles)
      printable_tempfiles.each { |file| file.unlink }

      printable.pdf = merged_pdf
      printable.pdf.name = "#{type}.pdf"
      printable.save!
    end
  end
end
