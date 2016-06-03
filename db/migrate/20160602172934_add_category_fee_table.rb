class AddCategoryFeeTable < ActiveRecord::Migration
  def change
    create_table :category_fees do |t|
        t.integer :category_id
        t.integer :market_id
        t.decimal :fee_pct, precision: 5, scale: 3

        t.timestamps
    end
  end
end
