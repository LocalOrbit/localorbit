class AddDeletedAtToMarketAddresses < ActiveRecord::Migration
  def change
    add_column :market_addresses, :deleted_at, :timestamp
  end
end
