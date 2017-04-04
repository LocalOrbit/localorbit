module Inventory
  class RepackOps
    class << self

      def repack_product(user, order, params)
        # repack x into y product

        t_id = ConsignmentTransaction.find(params[:transaction_id])

        repack_lot_id = t_id.lot_id
        repack_qty = Integer(params['repack_qty'])
        repack_into_product_id = params['repack_product_id']

        # Update inventory of repack product
        repack_into_product = Product.find(repack_into_product_id)
        repack_product_unit_qty = repack_into_product.unit_quantity

        lot_number = Inventory::Utils.generate_lot_number
        repack_into_qty = (repack_qty/repack_product_unit_qty).floor
        lot = Inventory::Utils.upsert_lot(repack_into_product, lot_number, repack_into_qty)

        # Add new order item - allocated from repack product lot
        order_item = OrderItem.new(
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
        order.items << order_item

        # Remove repack quantity from original lot
        repack_from_lot = Lot.find(repack_lot_id)
        repack_from_lot.quantity = repack_from_lot.quantity - (repack_into_qty * repack_product_unit_qty)

        # Add consignment transactions
        ct_parent = CreateConsignmentTransaction.perform(user: user, order: order, holdover: false, repack: true)

        ct_orig = ConsignmentTransaction.create(
            parent_id: params[:transaction_id],
            market_id: order.market.id,
            transaction_type: 'REPACK',
            order_id: order.id,
            product_id: t_id.product_id,
            quantity: repack_into_qty * repack_product_unit_qty,
            master: true
        )
        ct_orig.save

        ct_dest = ConsignmentTransaction.create(
            parent_id: ct_parent.transaction_id,
            market_id: order.market.id,
            transaction_type: 'REPACK',
            order_id: order.id,
            product_id: repack_into_product_id,
            quantity: repack_into_qty,
        )
        ct_dest.save
        Audit.create!(user_id:user.id, action:"create", auditable_type: "ConsignmentTransaction", auditable_id: order.id, audited_changes: {'transaction_type' => 'Repack', 'quantity' => repack_into_qty * repack_product_unit_qty, 'repack_product_id' => repack_into_product_id})

      end

      def unrepack_product(order, params)
      end

      def can_repack_product?
      end

    end
  end
end