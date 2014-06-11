class AddImageUidToPromotion < ActiveRecord::Migration
  def change
    add_column :promotions, :image_uid, :string
  end
end
