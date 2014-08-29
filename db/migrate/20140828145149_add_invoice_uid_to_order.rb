class AddInvoiceUidToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :invoice_pdf_uid, :string
    add_column :orders, :invoice_pdf_name, :string
  end
end
