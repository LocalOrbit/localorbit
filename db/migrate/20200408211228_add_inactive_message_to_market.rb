class AddInactiveMessageToMarket < ActiveRecord::Migration
  def change
    add_column :markets, :organization_inactive_note, :text
  end
end
