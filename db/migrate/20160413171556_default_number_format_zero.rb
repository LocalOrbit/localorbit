class DefaultNumberFormatZero < ActiveRecord::Migration
  def change
  	change_column :markets, :number_format_numeric, :integer, default: 0
  end
end
