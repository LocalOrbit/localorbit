class AddInactiveAtToDeliverySchedules < ActiveRecord::Migration
  def change
    add_column :delivery_schedules, :inactive_at, :datetime
  end
end
