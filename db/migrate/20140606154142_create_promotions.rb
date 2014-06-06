class CreatePromotions < ActiveRecord::Migration
  def change
    create_table :promotions do |t|
      t.integer :market_id
      t.integer :product_id
      t.string :name
      t.string :title
      t.text :body
      t.boolean :active
    end
  end
end
