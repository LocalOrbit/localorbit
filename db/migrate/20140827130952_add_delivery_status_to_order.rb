class AddDeliveryStatusToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :delivery_status, :string
  end
end
