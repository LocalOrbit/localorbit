class SetupBalancedForExistingDataAgain < ActiveRecord::Migration
  class Organization < ActiveRecord::Base
  end
  class Market < ActiveRecord::Base
  end

  def up
    Organization.where(balanced_customer_uri: nil).find_each do |e|
      CreateBalancedCustomerForEntity.perform(entity: e)
    end

    Market.where(balanced_customer_uri: nil).find_each do |e|
      CreateBalancedCustomerForEntity.perform(entity: e)
    end
  end

  def down
    # nothing to do
  end
end
