class AddCyclesToDeliverySchedules < ActiveRecord::Migration
  def change
    add_column :delivery_schedules, :delivery_cycle, :string
    add_column :delivery_schedules, :day_of_month, :integer
    add_column :delivery_schedules, :week_interval, :integer
  end
end
