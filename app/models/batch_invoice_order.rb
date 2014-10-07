class BatchInvoiceOrder < ActiveRecord::Base
  belongs_to :batch_invoice
  belongs_to :order
end
