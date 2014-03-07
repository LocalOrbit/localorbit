class AddPhoneToMarketAddresses < ActiveRecord::Migration
  def change
    add_column :market_addresses, :phone, :string
    add_column :market_addresses, :fax, :string
  end
end
