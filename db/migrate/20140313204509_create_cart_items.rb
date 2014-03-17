class CreateCartItems < ActiveRecord::Migration
  def change
    create_table :cart_items do |t|
      t.references :cart, index: true
      t.references :product, index: true
      t.integer :quantity, default: 0, null: false

      t.timestamps
    end
  end
end
