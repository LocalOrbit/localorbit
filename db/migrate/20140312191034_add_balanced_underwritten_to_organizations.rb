class AddBalancedUnderwrittenToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :balanced_underwritten, :boolean, default: false, null: false
  end
end
