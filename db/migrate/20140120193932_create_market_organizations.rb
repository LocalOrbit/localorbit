class CreateMarketOrganizations < ActiveRecord::Migration
  def change
    create_table :market_organizations do |t|
      t.integer :market_id
      t.integer :organization_id

      t.timestamps
    end
  end
end
