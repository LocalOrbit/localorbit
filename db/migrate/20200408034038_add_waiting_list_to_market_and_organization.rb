class AddWaitingListToMarketAndOrganization < ActiveRecord::Migration
  def change
    add_column :markets, :waiting_list_enabled, :boolean, default: false
    add_column :markets, :waiting_list_note, :text
    add_column :organizations, :on_waiting_list, :boolean, default: false
  end
end
