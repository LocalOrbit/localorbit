class AddNotNullConstraintOrderOrderType < ActiveRecord::Migration
  def change
    change_column :orders, :order_type, :string, :null => false, :default => 'sales'
  end
end
