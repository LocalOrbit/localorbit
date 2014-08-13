class ChangeOrganizationsActive < ActiveRecord::Migration
  def up
    change_column_default :organizations, :active, false
  end

  def down
    change_column_default :organizations, :active, true
  end
end
