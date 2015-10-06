class FixDeliveryScheduleColumn < ActiveRecord::Migration
  def change
  	remove_column :delivery_schedules, :toggle_on
  end
end
