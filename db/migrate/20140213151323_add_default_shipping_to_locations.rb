class AddDefaultShippingToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :default_shipping, :boolean, null: false, default: false
  end
end
