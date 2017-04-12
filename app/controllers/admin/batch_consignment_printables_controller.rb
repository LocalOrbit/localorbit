module Admin
  class BatchConsignmentPrintableStatus
    def self.status_of(batch_consignment_printable)
      {
        generation_status: batch_consignment_printable.generation_status,
        generation_progress: batch_consignment_printable.generation_progress,
        pdf_uri: batch_consignment_printable.pdf ? batch_consignment_printable.pdf.remote_url : nil,
        errors: []
      }
    end
  end

  class BatchConsignmentPrintablesController < ApplicationController
    before_action :load_batch_consignment_printable
    respond_to :json, only: :progress

    def show
    end

    def progress
      respond_with BatchConsignmentPrintableStatus.status_of(@batch_consignment_printable)
    end

    private
    def load_batch_consignment_printable
      id = params.require(:id)
      @batch_consignment_printable = BatchConsignmentPrintable.for_user(current_user).find(id)
    end
  end
end
