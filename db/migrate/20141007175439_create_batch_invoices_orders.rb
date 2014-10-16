class CreateBatchInvoicesOrders < ActiveRecord::Migration
  def change
    create_table :batch_invoices_orders do |t|
      t.integer :batch_invoice_id
      t.integer :order_id

      t.timestamps
    end
    add_index :batch_invoices_orders, [:order_id, :batch_invoice_id]
    add_index :batch_invoices_orders, :order_id
    add_index :batch_invoices_orders, :batch_invoice_id
  end

end
