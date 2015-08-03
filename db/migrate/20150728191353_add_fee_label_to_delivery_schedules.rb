class AddFeeLabelToDeliverySchedules < ActiveRecord::Migration
  def change
    add_column :delivery_schedules, :fee_label, :string, default: 'Delivery Fee'
  end
end
