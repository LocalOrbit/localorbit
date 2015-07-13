class AddDefaultStatusToMarketAddresses < ActiveRecord::Migration
  def change
  	add_column :market_addresses, :default, :boolean
  end
end
