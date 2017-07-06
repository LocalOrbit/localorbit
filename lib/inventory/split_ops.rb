module Inventory
  class SplitOps
    class << self

=begin
  Splitting consignment inventory requires:
  1. Parent Product
  2. Unit quantity that can be evenly divided

  Split can be done from catalog screen. User is presented with pre-configured split options

  Split creates a new lot under the eligible child product with the new quantity based upon the unit quantity

     * Removes one unit from an inventory record and applies it to a new inventory record using a child product of a lesser quantity as a basis.
     * Example: A seller has green beans in inventory. The base units for the beans are 20lbs.
     * Current Amount = 100lbs, Quantity = 5.
     * A child product, is defined whose base unit is 2lbs.
     * The green beans are "split" from the existing inventory record into a new inventory record for the 2lb green beans.
     * Amounts in inventory after the split are:
     * Original (20lb base unit): Current Quantity = 4, Current Amount = 80.
     * Current Quantity = Current Quantity - 1
     * Current Amount = Current Amount - Product.Quantity (on the product table "quantity" is "base" units as Inventory.Current_Amount is "base" units)
     *
     * New (2lb base unit): Current Quantity = 10, Current Amount = 20.

=end

      def split_product(market_id, orig_product_id, dest_product_id, orig_lot_id, quantity)
        orig_product = Product.find(orig_product_id)
        orig_lot = Lot.find(orig_lot_id)
        orig_lot_order = orig_lot.number.split('-')[0]
        order = Order.find(orig_lot_order)
        order_item = OrderItem.where(order_id: order.id, product_id: orig_product_id).first
        dest_product = Product.find(dest_product_id)
        #lot_number = Inventory::Utils.generate_lot_number(order)
        lot_number = orig_lot.number
        dest_lot = Inventory::Utils.upsert_lot(dest_product, lot_number, 0, true)

        orig_unit_quantity = orig_product.unit_quantity
        dest_unit_quantity = dest_product.unit_quantity

        qty = Integer(quantity)
        if qty > orig_lot.quantity
          qty = orig_lot.quantity
        end

        orig_lot.quantity = orig_lot.quantity - qty
        dest_lot.quantity = dest_lot.quantity + ((orig_unit_quantity / dest_unit_quantity) * qty)
        dest_lot.storage_location_id = orig_lot.storage_location_id

        orig_ct = ConsignmentTransaction.where(order_id: order.id, transaction_type: 'PO', product_id: orig_product.id).first

        ct = ConsignmentTransaction.create(
            market_id: market_id,
            transaction_type: 'SPLIT',
            product_id: orig_product.id,
            child_product_id: dest_product.id,
            lot_id: orig_lot.id,
            child_lot_id: dest_lot.id,
            quantity: qty,
            parent_id: orig_ct.id,
        )
        ct.save

        orig_lot.save
        dest_lot.save

        # Decrement quantity of original transaction
        #orig_ct.quantity = orig_ct.quantity - qty
        #orig_ct.save

        split_trans = ConsignmentTransaction.where(transaction_type: 'PO', child_product_id: dest_product.id, child_lot_id: dest_lot.id).first

        if split_trans.nil?
          # Add split product to PO
          po_ct = ConsignmentTransaction.create(
              market_id: order.market.id,
              transaction_type: 'PO',
              order_id: order.id,
              order_item_id: order_item.id,
              lot_id: dest_lot.id,
              delivery_date: order.delivery.deliver_on,
              product_id: dest_product.id,
              quantity: ((orig_unit_quantity / dest_unit_quantity) * qty),
              sale_price: order_item.unit_price,
              net_price: order_item.net_price,
              parent_id: ct.id
          )
          po_ct.save
        else
          split_trans.quantity = split_trans.quantity + ((orig_unit_quantity / dest_unit_quantity) * qty)
          split_trans.save!
        end

      end

      def unsplit_product(product_id)
        child_product = Product.find(product_id)
        parent_ct = ConsignmentTransaction.where(transaction_type: 'SPLIT', child_product_id: child_product.id, deleted_at: nil).last
        child_po_ct = ConsignmentTransaction.where(transaction_type: 'PO', product_id: child_product.id, deleted_at: nil).last
        child_lot = Lot.find(parent_ct.child_lot_id)

        parent_product = Product.find(child_product.parent_product_id)
        parent_lot = Lot.find(parent_ct.lot_id)

        quantity = parent_ct.quantity

        child_unit_quantity = child_product.unit_quantity
        parent_unit_quantity = parent_product.unit_quantity

        child_lot.quantity = child_lot.quantity - ((parent_unit_quantity / child_unit_quantity) * Integer(quantity))
        parent_lot.quantity = parent_lot.quantity + quantity

        child_lot.save
        parent_lot.save

        child_po_ct.quantity = child_po_ct.quantity - ((parent_unit_quantity / child_unit_quantity) * Integer(quantity))
        if child_po_ct.quantity == 0
          child_po_ct.soft_delete
        else
          child_po_ct.save!
        end

        parent_ct.soft_delete
      end

      def can_split_product?(product)
        product.parent_id.present? && product.unit_quantity % 2 == 0
      end

      def can_unsplit_product?(product_id)
        ConsignmentTransaction.where(transaction_type: 'SO', product_id: product_id, deleted_at: nil).length == 0
      end
    end
  end
end