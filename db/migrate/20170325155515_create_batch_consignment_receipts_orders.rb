class CreateBatchConsignmentReceiptsOrders < ActiveRecord::Migration
  def change
    create_table :batch_consignment_receipt_orders do |t|
      t.integer :batch_consignment_receipt_id
      t.integer :order_id

      t.timestamps
    end

    #add_index :batch_consignment_receipts_orders, [:order_id, :batch_consignment_receipt_id]
    #add_index :batch_consignment_receipts_orders, :order_id
    #add_index :batch_consignment_receipts_orders, :batch_consignment_receipt_id
  end
end
