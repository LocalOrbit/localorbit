class AddSegmentsToLots < ActiveRecord::Migration
  def change
    add_column :lots, :market_id, :integer
    add_column :lots, :organization_id, :integer
  end
end
