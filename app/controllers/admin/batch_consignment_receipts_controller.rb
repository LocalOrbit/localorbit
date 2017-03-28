module Admin
  class BatchConsignmentReceiptStatus
    def self.status_of(batch_consignment_receipt)
      {
        generation_status: batch_consignment_receipt.generation_status,
        generation_progress: batch_consignment_receipt.generation_progress,
        pdf_uri: batch_consignment_receipt.pdf ? batch_consignment_receipt.pdf.remote_url : nil,
        errors: []
      }
    end
  end

  class BatchConsignmentReceiptsController < ApplicationController
    before_action :load_batch_consignment_receipt
    respond_to :json, only: :progress

    def show
    end

    def progress
      respond_with BatchConsignmentReceiptStatus.status_of(@batch_consignment_receipt)
    end

    private
    def load_batch_consignment_receipt
      id = params.require(:id)
      @batch_consignment_receipt = BatchConsignmentReceipt.for_user(current_user).find(id)
    end
  end
end
