class CreateRoleTable < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name
      t.string :activities, array: true, length: 30, using: 'gin', default: '{}'
      t.timestamps
    end

    create_table :users_roles, id: false do |t|
      t.belongs_to :user, index: true
      t.belongs_to :role, index: true
    end
  end
end
