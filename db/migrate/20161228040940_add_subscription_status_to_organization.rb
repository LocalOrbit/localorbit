class AddSubscriptionStatusToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :subscription_status, :string
  end
end
