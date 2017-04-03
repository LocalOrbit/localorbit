module Inventory
  class HoldoverOps
    class << self

=begin
AKA Transfer
Product is removed from the current PO, and moved to another PO (new or existing). This allows the grower to be paid for their entire invoice within a timely fashion

=end

      def holdover_product(order, params)

        t_id = ConsignmentTransaction.find(params[:transaction_id])

        if params[:holdover_po] != ""
          dest_order = Order.find(params[:holdover_po])
        else
          # Create new Purchase Order
          dest_order = Order.create(
              payment_provider: order.payment_provider,
              placed_by: order.placed_by,
              order_number: OrderNumber.new(order.market).id,
              organization: order.organization,
              market: order.market,
              delivery: order.delivery,
              discount: order.discount,
              billing_organization_name: order.billing_organization_name,
              billing_address: order.billing_address,
              billing_city: order.billing_city,
              billing_state: order.billing_state,
              billing_zip: order.billing_zip,
              billing_phone: order.billing_phone,
              payment_status: "unpaid",
              delivery_status: "pending",
              payment_method: order.payment_method,
              payment_note: nil,
              delivery_fees: order.delivery_fees,
              total_cost: order.total_cost,
              placed_at: Time.current,
              order_type: order.order_type,
              delivery_address: order.delivery_address,
              delivery_city: order.delivery_zip,
              delivery_state: order.delivery_zip,
              delivery_zip: order.delivery_zip
          )
          dest_delivery = order.delivery
          dest_delivery.update_attributes(deliver_on: params[:holdover_delivery_date], buyer_deliver_on: params[:holdover_delivery_date])
          dest_order.delivery = dest_delivery
          dest_order.save
        end

        # Add Items to new PO
        orig_item = OrderItem.find(t_id.order_item_id)
        dest_item = OrderItem.new(orig_item.attributes.reject{ |k| k == 'id' })
        dest_item.quantity = params[:holdover_qty]
        dest_item.quantity_delivered = nil
        dest_item.delivery_status = 'pending'

        #if dest_item.quantity_delivered > Integer(params[:holdover_qty])
        #  dest_item.quantity_delivered = Integer(params[:holdover_qty])
        #end
        dest_order.items << dest_item

        ct_parent = CreateConsignmentTransaction.perform(order: dest_order)

        # Remove Items from original PO
        orig_item.update_attributes(:quantity => orig_item.quantity - Integer(params[:holdover_qty]))
        if orig_item.quantity_delivered > Integer(params[:holdover_qty])
          orig_item.update_attributes(:quantity_delivered => orig_item.quantity_delivered - Integer(params[:holdover_qty]))
        end

        # Create Transaction entry
        ct_orig = ConsignmentTransaction.create(
            parent_id: params[:transaction_id],
            market_id: order.market.id,
            transaction_type: 'HOLDOVER',
            order_id: order.id,
            product_id: t_id.product_id,
            quantity: params[:holdover_qty],
            holdover_order_id: dest_order.id,
            holdover_master: true
        )
        ct_orig.save

        ct_dest = ConsignmentTransaction.create(
            parent_id: ct_parent.transaction_id,
            market_id: order.market.id,
            transaction_type: 'HOLDOVER',
            order_id: dest_order.id,
            product_id: t_id.product_id,
            quantity: 0,
            holdover_order_id: order.id
        )
        ct_dest.save
      end

      def unholdover_product(params)
        t_id = ConsignmentTransaction.find(params[:transaction_id])

        # Remove new order
        new_order = Order.find(t_id.holdover_order_id)
        new_order.soft_delete

        # Adjust qty of order item
        orig_product = OrderItem.where(order_id: t_id.order_id, product_id: t_id.product_id).first
        orig_product.quantity = orig_product.quantity + t_id.quantity
        if orig_product.quantity_delivered > 0
          orig_product.quantity_delivered = orig_product.quantity_delivered + t_id.quantity
        end
        orig_product.save

        # Remove holdover consignment transactions
        dest_t_ids = ConsignmentTransaction.where(order_id: t_id.holdover_order_id)
        dest_t_ids.each do |trans|
          trans.soft_delete
        end
        t_id.soft_delete

      end

      def can_holdover_product?
      end
    end
  end
end