class AddConsignmentFieldsToOrderTemplateItems < ActiveRecord::Migration
  def change
    add_column :order_template_items, :sale_price, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :order_template_items, :net_price, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :order_template_items, :lot_id, :integer
  end
end
