class CreateExternalProducts < ActiveRecord::Migration
  def change
    create_table :external_products do |t|
      # base64 encoded SHA1
      t.string :contrived_key, length: 27, null: false
      t.integer :organization_id, null: false

      t.text :source_data_json
      t.datetime :batch_updated_at

      t.timestamps
    end

    add_index :external_products, [:contrived_key, :organization_id], unique: true
    add_index :external_products, [:organization_id, :batch_updated_at]
    add_column :products, :external_product_id, :integer, unique: true, index: true
  end
end
