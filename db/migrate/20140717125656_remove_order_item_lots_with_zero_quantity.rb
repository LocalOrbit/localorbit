class RemoveOrderItemLotsWithZeroQuantity < ActiveRecord::Migration
  class OrderItemLot < ActiveRecord::Base; end

  def up
    OrderItemLot.delete_all(quantity: 0)
  end

  def down
  end
end
