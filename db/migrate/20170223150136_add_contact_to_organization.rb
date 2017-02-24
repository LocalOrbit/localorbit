class AddContactToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :contact_first_name, :string
    add_column :organizations, :contact_last_name, :string
    add_column :organizations, :contact_email, :string
  end
end
