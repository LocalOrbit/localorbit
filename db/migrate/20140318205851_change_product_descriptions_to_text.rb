class ChangeProductDescriptionsToText < ActiveRecord::Migration
  def up
    change_column :products, :short_description, :text
    change_column :products, :long_description, :text
  end

  def down
    change_column :products, :short_description, :string
    change_column :products, :long_description, :string
  end
end
