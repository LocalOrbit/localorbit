class InitializeBatchConsignmentPrintable
  include Interactor

  def perform
    require_in_context(:user,:orders)
    begin
      if orders.present?
        context[:batch_consignment_printable] = BatchConsignmentPrintable.create!(user: user, orders: orders)
      else
        fail!(message: "Please select one or more orders to generate.")
      end
    rescue Exception => e
      begin 
        batch_printable = BatchConsignementPrintable.create(user: user, orders:[], generation_status: BatchConsignmentPrintable::GenerationStatus::Failed)
        GenerateBatchConsignmentPrintablePdf::BatchConsignmentPrintableUpdater.record_error!(batch_consignment_printable,
                                                                   task: "Initializing batch printable",
                                                                   message: "Selected order ids: #{orders.map do |o| o.id end.inspect}",
                                                                   exception: e.inspect,
                                                                   backtrace: e.backtrace)

      rescue Exception => e
        # Fuhgetaboutit
      end
      fail!(message: "There was an error trying to generate these docs.")
    end
  end

end
