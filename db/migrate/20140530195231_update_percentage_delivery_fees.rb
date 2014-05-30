class UpdatePercentageDeliveryFees < ActiveRecord::Migration
  def up
    DeliverySchedule.where(fee_type: 'percent').each do |ds|
      ds.update(fee: ds.fee * 100) if (0..1) === ds.fee
    end
  end

  def down
    DeliverySchedule.where(fee_type: 'percent').each do |ds|
      ds.update(fee: ds.fee / 100)
    end
  end
end
