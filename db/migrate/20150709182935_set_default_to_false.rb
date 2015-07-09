class SetDefaultToFalse < ActiveRecord::Migration
  def change
  	change_column :market_addresses, :billing, :boolean, default: false
  	change_column :market_addresses, :default, :boolean, default: false
  end
end
