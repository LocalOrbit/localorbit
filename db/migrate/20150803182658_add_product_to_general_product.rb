class AddProductToGeneralProduct < ActiveRecord::Migration
  def change
    add_reference :products, :general_product, index: true
  end
end
