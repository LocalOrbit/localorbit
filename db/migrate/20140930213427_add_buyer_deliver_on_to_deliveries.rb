class AddBuyerDeliverOnToDeliveries < ActiveRecord::Migration
  class Delivery < ActiveRecord::Base;end

  def change
    add_column :deliveries, :buyer_deliver_on, :datetime
    reversible do |dir|
      dir.up do
        say_with_time "Copying deliver_on fields into buyer_deliver_on..." do
          Delivery.all.each do |d|
            d.update_attribute :buyer_deliver_on, d.deliver_on
          end
        end
      end
    end
  end
end
