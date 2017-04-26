class GenerateBatchConsignmentPrintablePdf
  include Interactor

  def perform
    BatchConsignmentPrintableUpdater.start_generation!(batch_consignment_printable)

    completed_count = 0
    printable_tempfiles = []
    batch_consignment_printable.orders.each do |order|
      begin
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

      rescue Exception => e
        BatchConsignmentPrintableUpdater.record_error!(batch_consignment_printable,
                                                     task: "Generating printable PDF",
                                                     message: "Unexpected exception in ConsignmentPrintablePdfGenerator",
                                                     exception: e.inspect,
                                                     backtrace: e.backtrace,
                                                     order: order)
      end

      completed_count += 1
      BatchConsignmentPrintableUpdater.update_generation_progress!(batch_consignment_printable, completed_count: completed_count)
    end

    merged_pdf = GhostscriptWrapper.merge_pdf_files(printable_tempfiles)
    printable_tempfiles.each { |file| file.unlink }

    BatchConsignmentPrintableUpdater.complete_generation!(batch_consignment_printable, pdf: merged_pdf, pdf_name: "#{type}.pdf")

  rescue Exception => e
    BatchConsignmentPrintableUpdater.record_error!(batch_consignment_printable,
                                                 task: "Generating batch printable PDF",
                                                 message: "Unexpected exception while processing and merging receipt PDFs",
                                                 exception: e.inspect,
                                                 backtrace: e.backtrace)
    BatchConsignmentPrintableUpdater.fail_generation!(batch_consignment_printable)
  end

  #
  # Helpers:
  #

  class BatchConsignmentPrintableUpdater
    class << self
      def start_generation!(batch_consignment_printable)
        batch_consignment_printable.update!(
            generation_progress: 0.0,
            generation_status: BatchConsignmentPrintable::GenerationStatus::Generating)
      end

      def update_generation_progress!(batch_consignment_printable, completed_count:)
        batch_consignment_printable.update!(
            generation_progress: 1.0 * completed_count / batch_consignment_printable.orders.count)
      end

      def complete_generation!(batch_consignment_printable, pdf:, pdf_name:)
        batch_consignment_printable.pdf = pdf
        batch_consignment_printable.pdf.name = pdf_name
        batch_consignment_printable.generation_progress = "1.0".to_d
        batch_consignment_printable.generation_status = BatchConsignmentPrintable::GenerationStatus::Complete
        batch_consignment_printable.save!
      end

      def fail_generation!(batch_consignment_printable)
        batch_consignment_printable.update!(
            generation_status: BatchConsignmentPrintable::GenerationStatus::Failed
        )
      end

      def record_error!(batch_consignment_printable, task:, message:, order: nil, exception: nil, backtrace: nil)
        if backtrace and Array === backtrace
          backtrace = backtrace.join("\n")
        end

        batch_consignment_printable.batch_consignment_printable_errors.create(
            task: task,
            message: message,
            exception: exception,
            backtrace: backtrace,
            order: order)

        if Rails.env.production?
          #Honeybadger.notify(
          #    error_class: "Generate Batch Printable PDF",
          #    error_message: message,
          #    parameters: {
          #        task: task,
          #        message: message,
          #        order_id: order ? order.id : nil,
          #        exception: exception,
          #        backtrace: backtrace })
        end
      end
    end
  end
end
