class OrderItemLot < ActiveRecord::Base
  belongs_to :order_item, inverse_of: :lots, autosave: true
  belongs_to :lot

  def number
    lot.number
  end
end
