class CreateProductDelivery < ActiveRecord::Migration
  def change
    create_table :product_deliveries do |t|
      t.integer :product_id
      t.integer :delivery_schedule_id
    end
  end
end
