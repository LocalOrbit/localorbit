class AddThumbUidToPromotions < ActiveRecord::Migration
  def change
    add_column :promotions, :thumb_uid, :string
  end
end
