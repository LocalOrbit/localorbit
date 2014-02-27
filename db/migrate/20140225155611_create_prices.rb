class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.references :product,      index: true
      t.references :market,       index: true
      t.references :organization, index: true
      t.integer    :min_quantity, null: false, default: 1
      t.decimal    :sale_price,  precision: 10, scale: 2

      t.timestamps
    end
  end
end
