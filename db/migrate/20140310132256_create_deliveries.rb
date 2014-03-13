class CreateDeliveries < ActiveRecord::Migration
  def change
    create_table :deliveries do |t|
      t.integer :delivery_schedule_id
      t.datetime :deliver_on
      t.datetime :cutoff_time

      t.timestamps
    end
  end
end
