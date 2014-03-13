class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :organization_id
      t.integer :market_id
      t.integer :delivery_id
      t.string :order_number
      t.datetime :placed_at
      t.datetime :invoiced_at
      t.datetime :invoice_due_date
      t.decimal :delivery_fees, precision: 10, scale: 2
      t.string :delivery_status
      t.decimal :total_cost, precision: 10, scale: 2
      t.string :delivery_address
      t.string :delivery_city
      t.string :delivery_state
      t.string :delivery_zip
      t.string :delivery_phone
      t.string :billing_organization_name
      t.string :billing_address
      t.string :billing_city
      t.string :billing_state
      t.string :billing_zip
      t.string :billing_phone
      t.string :payment_status
      t.string :payment_method
      t.string :payment_note
      t.text :notes

      t.timestamps
    end
  end
end
