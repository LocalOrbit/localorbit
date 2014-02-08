class CreateLots < ActiveRecord::Migration
  def change
    create_table :lots do |t|
      t.references :product, index: true
      t.datetime :good_from
      t.datetime :expires_at
      t.integer :quantity
      t.string :number

      t.timestamps
    end
  end
end
