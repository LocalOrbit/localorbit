class AddQbItemIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :qb_item_id, :integer
  end
end
