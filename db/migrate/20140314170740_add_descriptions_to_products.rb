class AddDescriptionsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :short_description, :string
    add_column :products, :long_description, :string
  end
end
