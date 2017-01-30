class AddBackgroundImgUidToMarkets < ActiveRecord::Migration
  def change
    add_column :markets, :background_img_uid, :string
  end
end
