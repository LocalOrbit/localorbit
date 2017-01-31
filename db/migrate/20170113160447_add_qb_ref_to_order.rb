class AddQbRefToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :qb_ref_id, :integer
  end
end
