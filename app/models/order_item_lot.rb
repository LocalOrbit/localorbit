class OrderItemLot < ActiveRecord::Base
  audited allow_mass_assignment: true
  belongs_to :order_item, inverse_of: :lots
  belongs_to :lot

  before_destroy :return_inventory_to_lot

  def number
    lot.number
  end

  protected

  def return_inventory_to_lot
    lot.increment!(:quantity, quantity)
  end
end
