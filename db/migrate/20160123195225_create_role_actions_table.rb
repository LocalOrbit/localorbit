class CreateRoleActionsTable < ActiveRecord::Migration
  def change
    create_table :role_actions do |t|
      t.string :description
      t.string :org_type, array: true, using: 'gin', default: '{}'
      t.string :section
      t.string :action
      t.string :plan_ids, array: true, using: 'gin', default: '{}'
    end
  end
end
