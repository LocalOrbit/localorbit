class AddProductToGeneralProduct < ActiveRecord::Migration
  def change
    add_reference :general_products, :general_product, index: true
  end
end
