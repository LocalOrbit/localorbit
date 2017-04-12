class RenameBatchConsignmentReceiptToBatchConsignmentPrintable < ActiveRecord::Migration
  def change
    rename_table :batch_consignment_receipts, :batch_consignment_printables
  end
end
