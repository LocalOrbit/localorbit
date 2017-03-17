class AddFieldsToConsignmentTransactions < ActiveRecord::Migration
  def change
    add_column :consignment_transactions, :created_at, :datetime
    add_column :consignment_transactions, :market_id, :integer
  end
end
