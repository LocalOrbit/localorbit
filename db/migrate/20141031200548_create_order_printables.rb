class CreateOrderPrintables < ActiveRecord::Migration
  def change
    create_table :order_printables do |t|
      t.integer :user_id
      t.integer :order_id
      t.boolean :include_product_names
      t.string :printable_type
      t.string :pdf_uid
      t.string :pdf_name

      t.timestamps
    end
  end
end
