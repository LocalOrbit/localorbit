class RenameBatchConsignmentReceiptErrorToBatchConsignmentPrintableError < ActiveRecord::Migration
  def change
    rename_table :batch_consignment_receipt_errors, :batch_consignment_printable_errors
    rename_column :batch_consignment_printable_errors, :batch_consignment_receipt_id, :batch_consignment_printable_id
  end
end
