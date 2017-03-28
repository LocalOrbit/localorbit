class UpdateLots
  include Interactor
  def perform
    return unless order.purchase_order?

    lot_number = generate_lot_number

    order.items.each do |item|
      lot = upsert_lot(item, lot_number)
      update_pending_so(item, lot)
    end
  end

  def upsert_lot(item, lot_number)
    lot = Lot.where("product_id = ? AND number = ? AND EXTRACT(YEAR FROM created_at) = ?", item.product.id, lot_number, Time.now.year.to_s).first
    if lot.present?
      lot.update_attribute(:quantity, item.quantity_delivered)
    else
      lot = Lot.create(
        product_id: item.product.id,
        number: lot_number,
        quantity: item.quantity_delivered
      )
    end

    lot
  end

  def update_pending_so(item, lot)
    # When SO has been placed against undelivered PO, and PO is delivered, the newly created lot needs to be assigned to the SO consignment transaction
    ct_po = ConsignmentTransaction.where(transaction_type: 'PO', order_id: order.id, product_id: item.product.id).first
    ct_so = ConsignmentTransaction.where(transaction_type: 'SO', parent_id: ct_po.id, product_id: item.product.id)
    ct_so.each do |so|
      so.lot_id = lot.id
      so.save
      lot.quantity = lot_quantity - item.quantity
      lot.save
    end
  end

  def generate_lot_number
    days = %w(A B C D E F G)
    current_time = Time.now

    weekday = days[current_time.wday]
    monthweek = (current_time.mday / 7.0).ceil

    "#{weekday}#{monthweek}"
  end
end
