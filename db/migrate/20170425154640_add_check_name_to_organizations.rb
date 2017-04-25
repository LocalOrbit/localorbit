class AddCheckNameToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :qb_check_name, :string
  end
end
