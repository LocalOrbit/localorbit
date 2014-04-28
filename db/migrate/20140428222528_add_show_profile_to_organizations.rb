class AddShowProfileToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :show_profile, :boolean, default: true
  end
end
