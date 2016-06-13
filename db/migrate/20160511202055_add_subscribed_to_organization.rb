class AddSubscribedToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :subscribed, :boolean
  end
end
