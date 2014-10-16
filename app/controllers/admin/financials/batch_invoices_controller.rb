module Admin::Financials
  class BatchInvoiceStatus
    def self.status_of(batch_invoice)
      {
        generation_status: batch_invoice.generation_status,
        generation_progress: batch_invoice.generation_progress,
        pdf_uri: batch_invoice.pdf ? batch_invoice.pdf.remote_url : nil,
        errors: []
      }
    end
  end

  class BatchInvoicesController < ApplicationController
    before_action :load_batch_invoice
    respond_to :json, only: :progress

    def show
    end

    def progress
      respond_with BatchInvoiceStatus.status_of(@batch_invoice)
    end

    private
    def load_batch_invoice
      id = params.require(:id)
      @batch_invoice = BatchInvoice.for_user(current_user).find(id)
    end
  end
end
