class RenameBatchConsignmentReceiptOrderToBatchConsignmentPrintableOrder < ActiveRecord::Migration
  def change
    rename_table :batch_consignment_receipts_orders, :batch_consignment_printables_orders
  end
end
