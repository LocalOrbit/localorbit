class AddCostToConsignmentTransaction < ActiveRecord::Migration
  def change
    add_column :consignment_transactions, :sale_price, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :consignment_transactions, :net_price, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
