class CreateRoleActionsTable < ActiveRecord::Migration
  def change
    create_table :role_actions do |t|
      t.string :description
      t.string :org_type
      t.string :section
      t.string :action
    end
  end
end
