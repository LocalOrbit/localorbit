class CreateOrderTemplateItems < ActiveRecord::Migration
  def change
    create_table :order_template_items do |t|
      t.integer :order_template_id, null: false
      t.integer :product_id, null: false
      t.integer :quantity, null: false

      t.timestamps
    end
  end
end
