class AddMasterToConsignmentTransaction < ActiveRecord::Migration
  def change
    add_column :consignment_transactions, :holdover_master, :boolean
  end
end
