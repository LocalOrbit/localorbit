class AddSignatureToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :signature_data, :text
  end
end
