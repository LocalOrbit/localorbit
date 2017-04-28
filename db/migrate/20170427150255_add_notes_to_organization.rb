class AddNotesToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :notes, :text
  end
end
