class CreateCrossSellingListProducts < ActiveRecord::Migration
  def change
    create_table :cross_selling_list_products do |t|
		t.references :cross_selling_list, index: true
		t.references :product, index: true
		t.boolean :active, default: true
    end
  end
end
