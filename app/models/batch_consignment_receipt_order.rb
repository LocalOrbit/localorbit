class BatchConsignmentReceiptOrder < ActiveRecord::Base
  belongs_to :batch_consignment_receipt
  belongs_to :order
end
