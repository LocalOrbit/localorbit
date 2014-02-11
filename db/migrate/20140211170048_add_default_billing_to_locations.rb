class AddDefaultBillingToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :default_billing, :boolean, null: false, default: false
  end
end
