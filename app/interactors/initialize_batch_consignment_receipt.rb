class InitializeBatchConsignmentReceipt
  include Interactor

  def perform
    require_in_context(:user,:orders)
    begin
      if orders.present?
        context[:batch_consignment_receipt] = BatchConsignmentReceipt.create!(user: user, orders: orders)
      else
        fail!(message: "Please select one or more receipts to generate.")
      end
    rescue Exception => e
      begin 
        batch_invoice = BatchConsignementReceipt.create(user: user, orders:[], generation_status: BatchConsignmentReceipt::GenerationStatus::Failed)
        GenerateBatchConsigmentReceiptPdf::BatchConsignmentReceiptUpdater.record_error!(batch_consignment_receipt,
                                                                   task: "Initializing batch receipt",
                                                                   message: "Selected order ids: #{orders.map do |o| o.id end.inspect}",
                                                                   exception: e.inspect,
                                                                   backtrace: e.backtrace)

      rescue Exception => e
        # Fuhgetaboutit
      end
      fail!(message: "There was an error trying to generate these receipts.")
    end
  end

end
