class AddQbToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :qb_org_id, :integer
  end
end
