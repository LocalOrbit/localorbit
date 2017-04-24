class AddChildProductToConsignmentTransactions < ActiveRecord::Migration
  def change
    add_column :consignment_transactions, :child_product_id, :integer
  end
end
