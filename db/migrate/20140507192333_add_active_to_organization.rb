class AddActiveToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :active, :boolean, default: true
  end
end
