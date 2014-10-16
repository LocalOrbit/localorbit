class InitializeBatchInvoice
  include Interactor

  def perform
    require_in_context(:user,:orders)
    begin
      if orders.present?
        context[:batch_invoice] = BatchInvoice.create!(user: user, orders: orders)
      else
        fail!(message: "Please select one or more invoices to preview.")
      end
    rescue Exception => e
      begin 
        batch_invoice = BatchInvoice.create(user: user, orders:[], generation_status: BatchInvoice::GenerationStatus::Failed)
        GenerateBatchInvoicePdf::BatchInvoiceUpdater.record_error!(batch_invoice,
                                                                   task: "Initializing batch invoice",
                                                                   message: "Selected order ids: #{orders.map do |o| o.id end.inspect}",
                                                                   exception: e.inspect,
                                                                   backtrace: e.backtrace)

      rescue Exception => e
        # Fuhgetaboutit
      end
      fail!(message: "There was an error trying to preview these invoices.")
    end
  end

end
