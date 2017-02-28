class AddDescriptionsToRoleActions < ActiveRecord::Migration
  def change
    add_column :role_actions, :published, :boolean, default: true
    add_column :role_actions, :help_text, :string
    add_column :role_actions, :grouping, :string
  end
end
