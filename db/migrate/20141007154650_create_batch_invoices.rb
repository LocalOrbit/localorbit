class CreateBatchInvoices < ActiveRecord::Migration
  def change
    create_table :batch_invoices do |t|
      t.integer :user_id
      t.string :pdf_uid
      t.string :pdf_name
      t.string :generation_status, default: "not_started", null: false
      t.decimal :generation_progress, precision: 5, scale: 2, default: 0.0, null: false
      t.timestamps
    end

    add_index :batch_invoices, :user_id
  end
end
