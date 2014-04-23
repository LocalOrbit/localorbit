class RenameMarketsBackground < ActiveRecord::Migration
  def change
    rename_column :markets, :background, :background_image
  end
end
