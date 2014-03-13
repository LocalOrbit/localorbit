class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
      t.references :market, index: true
      t.references :organization, index: true
      t.references :delivery, index: true
      t.references :location, index: true

      t.timestamps
    end
  end
end
