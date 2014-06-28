class AddDeletedAtToMarketOrganizations < ActiveRecord::Migration
  def change
    add_column :market_organizations, :deleted_at, :datetime
  end
end
