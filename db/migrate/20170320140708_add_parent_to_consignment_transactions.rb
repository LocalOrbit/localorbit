class AddParentToConsignmentTransactions < ActiveRecord::Migration
  def change
    add_column :consignment_transactions, :parent_id, :integer
  end
end
