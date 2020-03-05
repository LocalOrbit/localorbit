class RemoveGcFromOrder < ActiveRecord::Migration
  def change
    remove_column :orders, :order_type, :string
    remove_column :orders, :payment_model, :string
    remove_column :orders, :sold_through, :boolean
    remove_column :organizations, :payment_model, :string
  end
end
