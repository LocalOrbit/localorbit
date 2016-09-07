class AddMinimumOrderToDeliverySchedules < ActiveRecord::Migration
  def change
    add_column :delivery_schedules, :order_minimum, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
