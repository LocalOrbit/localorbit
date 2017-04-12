class RenameBatchConsignmentReceiptErrorToBatchConsignmentPrintableError < ActiveRecord::Migration
  def change
    rename_table :batch_consignment_receipt_errors, :batch_consignment_printable_errors
  end
end
