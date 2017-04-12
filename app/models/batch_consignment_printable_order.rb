class BatchConsignmentPrintableOrder < ActiveRecord::Base
  belongs_to :batch_consignment_printable
  belongs_to :order
end
