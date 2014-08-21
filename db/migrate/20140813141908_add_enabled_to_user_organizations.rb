class AddEnabledToUserOrganizations < ActiveRecord::Migration
  def change
    add_column :user_organizations, :enabled, :boolean, default: true
  end
end
