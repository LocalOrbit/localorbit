class AddReceiptToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :receipt_pdf_uid, :string
    add_column :orders, :receipt_pdf_name, :string
  end
end
