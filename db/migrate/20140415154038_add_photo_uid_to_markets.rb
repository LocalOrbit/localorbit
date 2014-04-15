class AddPhotoUidToMarkets < ActiveRecord::Migration
  def change
    add_column :markets, :photo_uid, :string
  end
end
