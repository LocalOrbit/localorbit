class AddChildLotToConsignmentTransactions < ActiveRecord::Migration
  def change
    add_column :consignment_transactions, :child_lot_id, :integer
  end
end
