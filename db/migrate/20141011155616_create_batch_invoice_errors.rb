class CreateBatchInvoiceErrors < ActiveRecord::Migration
  def change
    create_table :batch_invoice_errors do |t|
      t.integer :batch_invoice_id
      t.string :task
      t.text :message
      t.text :exception
      t.text :backtrace
      t.integer :order_id

      t.timestamps
    end
  end
end
