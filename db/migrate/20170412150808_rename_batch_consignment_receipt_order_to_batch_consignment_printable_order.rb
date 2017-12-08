class RenameBatchConsignmentReceiptOrderToBatchConsignmentPrintableOrder < ActiveRecord::Migration
  def change
    rename_table :batch_consignment_receipts_orders, :batch_consignment_printables_orders
    rename_column :batch_consignment_printables_orders, :batch_consignment_receipt_id, :batch_consignment_printable_id
  end
end
