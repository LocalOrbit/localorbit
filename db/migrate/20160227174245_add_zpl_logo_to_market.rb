class AddZplLogoToMarket < ActiveRecord::Migration
  def change
    add_column :markets, :zpl_logo, :text
  end
end
