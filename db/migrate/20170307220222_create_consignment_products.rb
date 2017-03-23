class CreateConsignmentProducts < ActiveRecord::Migration
  def change
    create_table :consignment_products do |t|
      t.integer :product_id, null: false
      t.integer :consignment_product_id, null: false
      t.integer :consignment_organization_id, null: false

      t.timestamps
    end
  end
end
