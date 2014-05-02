class AddPayeeIndexOnPayments < ActiveRecord::Migration
  def change
    add_index :payments, [:payee_id, :payee_type]
  end
end
