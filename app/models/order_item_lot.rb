class OrderItemLot < ActiveRecord::Base
  belongs_to :order_item, inverse_of: :lots
  belongs_to :lot

  before_destroy :return_inventory_to_lot

  def number
    lot.number
  end

  protected

  def return_inventory_to_lot
    lot.update(quantity: lot.quantity + quantity)
  end
end
