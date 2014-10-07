class GenerateBatchInvoicePdf
  include Interactor

  def perform
    BatchInvoiceUpdater.start_generation!(batch_invoice)

    completed_count = 0
    invoice_tempfiles = []
    batch_invoice.orders.each do |order|
      begin
        made = MakeInvoicePdfTempFile.perform(order: order)
        if made.success?
          invoice_tempfiles << made.file
        else
          BatchInvoiceUpdater.record_error!(batch_invoice, 
                                            task: "Generating invoice PDF",
                                            message: made.message,
                                            order: order)
        end
      rescue Exception => e
        BatchInvoiceUpdater.record_error!(batch_invoice, 
                                          task: "Generating invoice PDF",
                                          message: "Unexpected exception in MakeInvoicePdfTempFile",
                                          exception: e.inspect,
                                          backtrace: e.backtrace,
                                          order: order)
      end

      completed_count += 1
      BatchInvoiceUpdater.update_generation_progress!(batch_invoice, completed_count: completed_count)
    end
    
    merged = MergePdfFiles.perform(files: invoice_tempfiles)
    BatchInvoiceUpdater.complete_generation!(batch_invoice, pdf: merged.pdf, pdf_name: "invoices.pdf")
  rescue Exception => e
    BatchInvoiceUpdater.record_error!(batch_invoice,
                                      task: "Generating batch invoice PDF",
                                      message: "Unexpected exception while processing and merging invoice PDFs",
                                      exception: e.inspect,
                                      backtrace: e.backtrace)
    BatchInvoiceUpdater.fail_generation!(batch_invoice)
  end

  class BatchInvoiceUpdater
    class << self
      def start_generation!(batch_invoice)
        batch_invoice.update!(
          generation_progress: 0.0, 
          generation_status: BatchInvoice::GenerationStatus::Generating)
      end

      def update_generation_progress!(batch_invoice, completed_count:)
        batch_invoice.update!(
          generation_progress: 1.0 * completed_count / batch_invoice.orders.count)
      end

      def complete_generation!(batch_invoice, pdf:, pdf_name:)
        batch_invoice.pdf = pdf
        batch_invoice.pdf.name = pdf_name
        batch_invoice.generation_progress = "1.0".to_d
        batch_invoice.generation_status = BatchInvoice::GenerationStatus::Complete
        batch_invoice.save!
      end

      def fail_generation!(batch_invoice)
        batch_invoice.update!(
          generation_status: BatchInvoice::GenerationStatus::Failed
        )
      end

      def record_error!(batch_invoice, task:, message:, order: nil, exception: nil, backtrace: nil)
        if backtrace and Array === backtrace
          backtrace = backtrace.join("\n")
        end

        batch_invoice.batch_invoice_errors.create(
          task: task,
          message: message,
          exception: exception,
          backtrace: backtrace,
          order: order)

        if Rails.env.production?
          Honeybadger.notify(
            error_class: "Generate Batch Invoice PDF",
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
