class AddLogoUidToMarkets < ActiveRecord::Migration
  def change
    add_column :markets, :logo_uid, :string
  end
end
