class AddBuyerDayToDeliverySchedules < ActiveRecord::Migration
  class DeliverySchedule < ActiveRecord::Base; end

  def change
    add_column :delivery_schedules, :buyer_day, :integer

    reversible do |dir|
      dir.up do
        say_with_time "Copying day fields into buyer_day..." do
          DeliverySchedule.all.each do |s|
            s.update_attribute :buyer_day, s.day
          end
        end
      end
    end
  end
end
