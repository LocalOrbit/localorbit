class AddOrganizationIdToMarket < ActiveRecord::Migration
  def change
    add_column :markets, :organization_id, :integer
  end
end
