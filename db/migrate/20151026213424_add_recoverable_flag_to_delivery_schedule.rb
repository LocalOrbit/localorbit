class AddRecoverableFlagToDeliverySchedule < ActiveRecord::Migration
  def change
    add_column :delivery_schedules, :is_recoverable, :boolean
  end
end
