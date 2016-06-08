class AddOrgRoleToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :org_type, :string
  end
end
