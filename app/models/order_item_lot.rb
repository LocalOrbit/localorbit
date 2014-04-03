class OrderItemLot < ActiveRecord::Base
  belongs_to :order_item, inverse_of: :lots
  belongs_to :lot

  def number
    lot.number
  end
end
