class AddNumberFormatToMarket < ActiveRecord::Migration
  def change
  	add_column :markets, :number_format_numeric, :integer, default: 0
  end
end
