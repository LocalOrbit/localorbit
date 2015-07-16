class AddDeletedAtToPrices < ActiveRecord::Migration
  def change
    add_column :prices, :deleted_at, :timestamp
  end
end
