class AddSubscriptionIdToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :subscription_id, :string
  end
end
