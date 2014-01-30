class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.text :name
      t.references :category, index: true
      t.references :organization, index: true

      t.timestamps
    end
  end
end
