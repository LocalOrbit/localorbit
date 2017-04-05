module Inventory
  class RepackOps
    class << self

      def repack_product(user, order, params)
        # repack x into y product

        t_id = ConsignmentTransaction.find(params[:transaction_id])

        repack_lot_id = t_id.lot_id
        repack_qty = Integer(params['repack_qty'])
        repack_into_product_id = params['repack_product_id']

        orig_order_item = OrderItem.find(t_id.order_item_id)

        # Update inventory of repack product
        repack_into_product = Product.find(repack_into_product_id)
        repack_product_unit_qty = repack_into_product.unit_quantity

        lot_number = Inventory::Utils.generate_lot_number
        repack_into_qty = (repack_qty/repack_product_unit_qty).floor
        if repack_into_qty > 0
          Inventory::Utils.upsert_lot(repack_into_product, lot_number, repack_into_qty)

          # Add new order item - allocated from repack product lot
          new_order_item = OrderItem.new(
              deliver_on_date: order.delivery.deliver_on,
              order: order,
              product: repack_into_product,
              name: repack_into_product.name,
              quantity: repack_into_qty,
              unit: repack_into_product.unit,
              product_fee_pct: 0,
              seller_name: repack_into_product.organization.name,
              delivery_status: "pending"
          )
          order.items << new_order_item

          # Remove repack quantity from original lot
          orig_order_item.quantity = orig_order_item.quantity - (repack_into_qty * repack_product_unit_qty)
          orig_order_item.quantity_delivered = orig_order_item.quantity_delivered - (repack_into_qty * repack_product_unit_qty)
          orig_order_item.save

          #repack_from_lot = Lot.find(repack_lot_id)
          #repack_from_lot.quantity = repack_from_lot.quantity - (repack_into_qty * repack_product_unit_qty)

          # Add consignment transactions
          ct_parent = CreateConsignmentTransaction.perform(user: user, order: order, holdover: false, repack: true)

          ct_orig = ConsignmentTransaction.create(
              parent_id: params[:transaction_id],
              market_id: order.market.id,
              transaction_type: 'REPACK',
              order_id: order.id,
              order_item_id: orig_order_item.id,
              product_id: t_id.product_id,
              quantity: repack_into_qty * repack_product_unit_qty,
              master: true
          )
          ct_orig.save

          ct_dest = ConsignmentTransaction.create(
              parent_id: ct_orig.id,
              market_id: order.market.id,
              transaction_type: 'REPACK',
              order_id: order.id,
              order_item_id: new_order_item.id,
              product_id: repack_into_product_id,
              quantity: repack_into_qty,
          )
          ct_dest.save
          Audit.create!(user_id:user.id, action:"create", auditable_type: "ConsignmentTransaction", auditable_id: order.id, audited_changes: {'transaction_type' => 'Repack', 'quantity' => repack_into_qty * repack_product_unit_qty, 'repack_product_id' => repack_into_product_id})
        end
      end

      def unrepack_product(user, order, params)
        # Get transactions
        child_ct = ConsignmentTransaction.find(params[:transaction_id])
        parent_ct = ConsignmentTransaction.where(parent_id: child_ct.id).first

        # Remove the child item
        parent_order_item = OrderItem.find(parent_ct.order_item_id)
        parent_order_item_lot = parent_order_item.lots.first
        parent_order_item_qty = parent_order_item.quantity
        parent_order_item.delete

        # Subtract qty from child product lot
        parent_order_item_lot.quantity = parent_order_item_lot.quantity - parent_order_item_qty

        # Add appropriate qty to parent product lot
        parent_product = Product.find(parent_ct.product_id)
        parent_unit_quantity = parent_product.unit_quantity

        # Increase parent item by appropriate qty
        child_order_item = OrderItem.find(child_ct.order_item_id)
        child_order_item.quantity = child_order_item.quantity + (parent_order_item_qty * parent_unit_quantity)
        if child_order_item.quantity_delivered > 0
          child_order_item.quantity_delivered = child_order_item.quantity
        end
        child_order_item.save

        # Remove repacked PO CT
        parent_po_ct = ConsignmentTransaction.where(transaction_type: 'PO', order_item_id: parent_ct.order_item_id).first
        parent_po_ct.soft_delete

        # Remove repack consignment transactions
        child_ct.soft_delete
        parent_ct.soft_delete

        # Create audit entry
        Audit.create!(user_id: user.id, action:"create", auditable_type: "ConsignmentTransaction", auditable_id: order.id, audited_changes: {'transaction_type' => 'Undo Repack', 'repack_product_id' => parent_product.id})

      end

      def can_repack_product?
      end

    end
  end
end