class AddDisplayTwitterAndFacebookToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :display_facebook, :bool, default: false
    add_column :organizations, :display_twitter, :bool, default: false
  end
end
