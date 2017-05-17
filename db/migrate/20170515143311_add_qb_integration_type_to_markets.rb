class AddQbIntegrationTypeToMarkets < ActiveRecord::Migration
  def change
    add_column :markets, :qb_integration_type, :string
  end
end
