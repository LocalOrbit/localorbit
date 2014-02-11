class AddSellerInfoFieldsToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :who_story, :text, null: false
    add_column :organizations, :how_story, :text, null: false
  end
end
