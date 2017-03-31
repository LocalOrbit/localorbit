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
        dest_product = Product.find(dest_product_id)
        lot_number = Inventory::Utils.generate_lot_number
        dest_lot = Inventory::Utils.upsert_lot(dest_product, lot_number, 0, true)

        orig_unit_quantity = orig_product.unit_quantity
        dest_unit_quantity = dest_product.unit_quantity

        qty = Integer(quantity)
        if qty > orig_lot.quantity
          qty = orig_lot.quantity
        end

        orig_lot.quantity = orig_lot.quantity - qty
        dest_lot.quantity = dest_lot.quantity + ((orig_unit_quantity / dest_unit_quantity) * qty)

        ct = ConsignmentTransaction.create(
            market_id: market_id,
            transaction_type: 'SPLIT',
            product_id: orig_product.id,
            child_product_id: dest_product.id,
            lot_id: orig_lot.id,
            child_lot_id: dest_lot.id,
            quantity: qty,
        )
        ct.save

        orig_lot.save
        dest_lot.save
      end

      def unsplit_product(product_id)
        child_product = Product.find(product_id)
        parent_ct = ConsignmentTransaction.where(transaction_type: 'SPLIT', child_product_id: child_product.id).last
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

        parent_ct.delete
      end

      def can_split_product?(product)
        product.parent_id.present? && product.unit_quantity % 2 == 0
      end

    end
  end
end