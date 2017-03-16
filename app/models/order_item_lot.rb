class OrderItemLot < ActiveRecord::Base
  audited allow_mass_assignment: true
  belongs_to :order_item, inverse_of: :lots
  belongs_to :lot

  before_destroy :return_inventory_to_lot
  before_create :check_po
  def number
    lot.number
  end

  protected

  def check_po
    if order_item.order.order_type == "purchase"
      self.quantity = 0
    end
  end

  def return_inventory_to_lot
    lot.increment!(:quantity, quantity)
  end
end
