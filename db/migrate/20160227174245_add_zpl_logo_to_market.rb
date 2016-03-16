class AddZplLogoToMarket < ActiveRecord::Migration
  def change
    add_column :markets, :zpl_logo, :text
    add_column :markets, :zpl_printer, :string
  end
end
