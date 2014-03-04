class AddImageUidToProducts < ActiveRecord::Migration
  def change
    add_column :products, :image_uid, :string
  end
end
