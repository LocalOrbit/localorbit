class SetupBalancedForExistingData < ActiveRecord::Migration
  def up
    Organization.where("balanced_customer_uri IS NOT NULL").find_each do |e|
      CreateBalancedCustomerForEntity.perform(entity: e)
    end

    Market.where("balanced_customer_uri IS NOT NULL").find_each do |e|
      CreateBalancedCustomerForEntity.perform(entity: e)
    end
  end

  def down
    # nothing to do
  end
end
