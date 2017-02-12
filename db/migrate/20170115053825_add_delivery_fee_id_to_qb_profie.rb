class AddDeliveryFeeIdToQbProfie < ActiveRecord::Migration
  def change
    add_column :qb_profiles, :delivery_fee_item_name, :string
    add_column :qb_profiles, :delivery_fee_item_id, :integer
  end
end
