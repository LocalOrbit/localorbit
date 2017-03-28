class CreateBatchConsignmentReceiptErrors < ActiveRecord::Migration
  def change
    create_table :batch_consignment_receipt_errors do |t|
      t.integer :batch_consignment_receipt_id
      t.string :task
      t.text :message
      t.text :exception
      t.text :backtrace
      t.integer :order_id

      t.timestamps
    end
  end
end
