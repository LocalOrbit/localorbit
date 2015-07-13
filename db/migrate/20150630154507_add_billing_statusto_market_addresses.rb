class AddBillingStatustoMarketAddresses < ActiveRecord::Migration
  def change
  	add_column :market_addresses, :billing, :boolean
  end
end
