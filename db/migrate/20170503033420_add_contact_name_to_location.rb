class AddContactNameToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :contact_name, :string
  end
end
