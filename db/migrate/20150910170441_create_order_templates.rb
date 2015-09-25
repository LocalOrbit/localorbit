class CreateOrderTemplates < ActiveRecord::Migration
  def change
    create_table :order_templates do |t|
      t.string :name, null: false
      t.integer :market_id, null: false

      t.timestamps
    end
  end
end
