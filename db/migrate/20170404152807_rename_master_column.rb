class RenameMasterColumn < ActiveRecord::Migration
  def change
    rename_column :consignment_transactions, :holdover_master, :master
  end
end
