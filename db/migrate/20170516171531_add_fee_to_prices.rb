class AddFeeToPrices < ActiveRecord::Migration
  def change
    add_column :prices, :fee, :integer
  end
end
