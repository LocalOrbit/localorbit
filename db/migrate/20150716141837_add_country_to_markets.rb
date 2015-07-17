class AddCountryToMarkets < ActiveRecord::Migration
  def change
    add_column :markets, :country, :string, default: 'US', null: false
  end
end
