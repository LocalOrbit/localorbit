class MergeOrder
  include Interactor

  def perform
    require_in_context(:user, :orig_order, :dest_order)
    return context.fail!(message: 'Origin and Destination orders must be different') if orig_order.id == dest_order.id
    return context.fail!(message: 'Origin and Destination orders must have same payment method') if orig_order.payment_method != dest_order.payment_method
    return context.fail!(message: 'Origin and Destination must have the same buyer') if orig_order.organization != dest_order.organization
    return context.fail!(message: 'Destination Order must be Undelivered') if dest_order.delivery_status == 'delivered'

    # Update qty of existing dest_order items
    orig_order.items.each do |o_item|
      dest_order.items.each do |d_item|
        if o_item.product_id == d_item.product_id
          d_item.quantity = d_item.quantity + o_item.quantity
          o_item.quantity = 0
          o_item.market_seller_fee = 0

          o_item.save!
          d_item.save!
        end
      end
    end

    # Add remaining items to dest_order
    orig_order.items.each do |o_item|
      if o_item.quantity > 0
        old_item = o_item.as_json
        old_item.delete "id"
        new_item = OrderItem.new(old_item)
        dest_order.items << new_item
        o_item.quantity = 0
        o_item.market_seller_fee = 0

        o_item.save!
      end
    end

    # Update order totals
    RemoveCredit.perform(order: orig_order)
    orig_order.update_total_cost
    orig_order.save!

    UpdatePurchase.perform(payment_provider: orig_order.payment_provider, order: orig_order)

    dest_order.update_total_cost
    dest_order.save!

    UpdatePurchase.perform(payment_provider: dest_order.payment_provider, order: dest_order)

    # Add order merge entry to audit trail
    aud_orig = Audit.create!(user_id:context[:user].id, action:"update", auditable_type: "Order", auditable_id: orig_order.id)
    aud_orig.update_attributes(audited_changes: { 'merge_order' => "Merge order: #{orig_order.order_number} into order: #{dest_order.order_number}"})

    aud_dest = Audit.create!(user_id:context[:user].id, action:"update", auditable_type: "Order", auditable_id: dest_order.id)
    aud_dest.update_attributes(audited_changes: { 'merge_order' => "Merge order: #{orig_order.order_number} into order: #{dest_order.order_number}"})
  end
end
