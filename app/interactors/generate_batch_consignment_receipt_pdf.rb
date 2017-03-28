class GenerateBatchConsignmentReceiptPdf
  include Interactor

  def perform
    BatchConsignmentReceiptUpdater.start_generation!(batch_consignment_receipt)

    completed_count = 0
    receipt_tempfiles = []
    batch_consignment_receipt.orders.each do |order|
      begin
        tempfile = Tempfile.new("tmp-receipt-#{order.order_number}")

        pdf_result = ConsignmentReceipts::ConsignmentReceiptPdfGenerator.generate_pdf(request:request, order:order, path:tempfile.path)

        receipt_tempfiles << tempfile
        
      rescue Exception => e
        BatchConsignmentReceiptUpdater.record_error!(batch_consignment_receipt,
                                          task: "Generating receipt PDF",
                                          message: "Unexpected exception in ConsignmentReceiptPdfGenerator",
                                          exception: e.inspect,
                                          backtrace: e.backtrace,
                                          order: order)
      end

      completed_count += 1
      BatchConsignmentReceiptUpdater.update_generation_progress!(batch_consignment_receipt, completed_count: completed_count)
    end
    
    merged_pdf = GhostscriptWrapper.merge_pdf_files(receipt_tempfiles)
    receipt_tempfiles.each { |file| file.unlink }

    BatchConsignmentReceiptUpdater.complete_generation!(batch_consignment_receipt, pdf: merged_pdf, pdf_name: "receipts.pdf")

  rescue Exception => e
    BatchConsignmentReceiptUpdater.record_error!(batch_consignment_receipt,
                                      task: "Generating batch receipt PDF",
                                      message: "Unexpected exception while processing and merging receipt PDFs",
                                      exception: e.inspect,
                                      backtrace: e.backtrace)
    BatchConsignmentReceiptUpdater.fail_generation!(batch_consignment_receipt)
  end

  #
  # Helpers:
  #

  class BatchConsignmentReceiptUpdater
    class << self
      def start_generation!(batch_consignment_receipt)
        batch_consignment_receipt.update!(
          generation_progress: 0.0, 
          generation_status: BatchConsignmentReceipt::GenerationStatus::Generating)
      end

      def update_generation_progress!(batch_consignment_receipt, completed_count:)
        batch_consignment_receipt.update!(
          generation_progress: 1.0 * completed_count / batch_consignment_receipt.orders.count)
      end

      def complete_generation!(batch_consignment_receipt, pdf:, pdf_name:)
        batch_consignment_receipt.pdf = pdf
        batch_consignment_receipt.pdf.name = pdf_name
        batch_consignment_receipt.generation_progress = "1.0".to_d
        batch_consignment_receipt.generation_status = BatchConsignmentReceipt::GenerationStatus::Complete
        batch_consignment_receipt.save!
      end

      def fail_generation!(batch_consignment_receipt)
        batch_consignment_receipt.update!(
          generation_status: BatchConsignmentReceipt::GenerationStatus::Failed
        )
      end

      def record_error!(batch_consignment_receipt, task:, message:, order: nil, exception: nil, backtrace: nil)
        if backtrace and Array === backtrace
          backtrace = backtrace.join("\n")
        end

        batch_consignment_receipt.batch_consignment_receipt_errors.create(
          task: task,
          message: message,
          exception: exception,
          backtrace: backtrace,
          order: order)

        if Rails.env.production?
          Honeybadger.notify(
            error_class: "Generate Batch Receipt PDF",
            error_message: message,
            parameters: {
              task: task, 
              message: message, 
              order_id: order ? order.id : nil, 
              exception: exception, 
              backtrace: backtrace })
        end
      end
    end
  end
end
