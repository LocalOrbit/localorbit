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
    if !order_item.order.nil? && order_item.order.purchase_order?
      self.quantity = 0
    end

    if !order_item.po_lot_id.nil? && order_item.po_lot_id > 0
      self.lot_id = order_item.po_lot_id
    end
  end

  def return_inventory_to_lot
    lot.increment!(:quantity, quantity)
  end
end
