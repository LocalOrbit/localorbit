class AddCountryToMarketAddresses < ActiveRecord::Migration
  def change
    add_column :market_addresses, :country, :string, default: 'US', null: false
    add_column :locations, :country, :string, default: 'US', null: false
  end
end
