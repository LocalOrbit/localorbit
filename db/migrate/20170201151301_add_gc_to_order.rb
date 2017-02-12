class AddGcToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :order_type, :string
    add_column :orders, :payment_model, :string
    add_column :orders, :sold_through, :boolean
  end
end
