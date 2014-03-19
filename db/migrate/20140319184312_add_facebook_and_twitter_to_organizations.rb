class AddFacebookAndTwitterToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :facebook, :string
    add_column :organizations, :twitter, :string
  end
end
