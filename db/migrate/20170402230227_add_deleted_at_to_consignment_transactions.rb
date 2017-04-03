class AddDeletedAtToConsignmentTransactions < ActiveRecord::Migration
  def change
    add_column :consignment_transactions, :deleted_at, :datetime
  end
end
