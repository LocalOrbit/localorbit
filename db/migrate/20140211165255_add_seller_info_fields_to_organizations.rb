class AddSellerInfoFieldsToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :who_story, :text
    add_column :organizations, :how_story, :text
  end
end
