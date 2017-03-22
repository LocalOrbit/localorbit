class UpdateLots
  include Interactor
  def perform
    return unless order.purchase_order?

    lot_number = generate_lot_number
    order.items.each do |item|
      upsert_lot(item, lot_number) if item.quantity_delivered > 0
    end
  end

  def upsert_lot(item, lot_number)
    lot = Lot.where("product_id = ? AND number = ? AND EXTRACT(YEAR FROM created_at) = ?", item.product.id, lot_number, Time.now.year.to_s).first
    if lot.present?
      lot.update_attribute(quantity: item.quantity_delivered)
    else
      lot = Lot.create(
        product_id: item.product.id,
        number: lot_number,
        quantity: item.quantity_delivered
      )
    end

    lot
  end

  def generate_lot_number
    'C1'
  end
end
