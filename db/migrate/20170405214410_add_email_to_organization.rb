class AddEmailToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :email, :string
  end
end
