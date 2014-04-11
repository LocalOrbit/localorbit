class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :payee_id
      t.string :payee_type
      t.string :payment_type
      t.decimal :amount, precision: 10, scale: 2, default: 0.0, null: false
      t.text :note

      t.timestamps
    end
  end
end
