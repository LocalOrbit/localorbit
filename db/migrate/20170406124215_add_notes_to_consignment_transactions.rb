class AddNotesToConsignmentTransactions < ActiveRecord::Migration
  def change
    add_column :consignment_transactions, :notes, :text
  end
end
