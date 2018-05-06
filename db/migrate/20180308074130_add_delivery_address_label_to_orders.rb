class AddDeliveryAddressLabelToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :delivery_address_label, :string
  end
end
