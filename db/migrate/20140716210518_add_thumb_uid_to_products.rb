class AddThumbUidToProducts < ActiveRecord::Migration
  def change
    add_column :products, :thumb_uid, :string
  end
end
