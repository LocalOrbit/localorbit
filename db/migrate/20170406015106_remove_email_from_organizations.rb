class RemoveEmailFromOrganizations < ActiveRecord::Migration
  def change
    remove_column :organizations, :email
  end
end
