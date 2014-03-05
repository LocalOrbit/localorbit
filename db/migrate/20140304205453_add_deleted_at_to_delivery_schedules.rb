class AddDeletedAtToDeliverySchedules < ActiveRecord::Migration
  def change
    add_column :delivery_schedules, :deleted_at, :datetime
  end
end
