class MergeOrder
  include Interactor

  def perform
    # Retrieve orig_order items
    if !orig_order.nil? && !dest_order.nil?
      orig_order = context[:orig_order]
      dest_order = context[:dest_order]

      orig_order_items = orig_order.items
      dest_order_items = dest_order.items

      # Update qty of existing dest_order items, and remove from array
      orig_order_items.each do |o_item|
        dest_order_items.each do |d_item|
          if o_item.product_id == d_item.product_id
            d_item.quantity = d_item.quantity + o_item.quantity
            o_item.quantity = 0

            o_item.save!
            d_item.save!
          end
        end
      end

      # Add remaining items to dest_order
      orig_order_items.each do |o_item|
        if o_item.quantity > 0
          old_item = o_item.as_json
          old_item.delete "id"
          new_item = OrderItem.new(old_item)
          dest_order_items << new_item
          o_item.quantity = 0
          o_item.save!
        end
      end

      # Update order totals
      RemoveDeliveryFee.perform(order: orig_order)
      RemoveCredit.perform(order: orig_order)
      orig_order.update_total_cost
      orig_order.save!

      dest_order.update_total_cost
      dest_order.save!

      # Add order merge entry to audit trail
      aud_orig = Audit.create!(user_id:context[:user].id, action:"update", auditable_type: "Order", auditable_id: orig_order.id)
      aud_orig.update_attributes(audited_changes: { 'merge_order' => "Merge order: #{orig_order.order_number} into order: #{dest_order.order_number}"})

      aud_dest = Audit.create!(user_id:context[:user].id, action:"update", auditable_type: "Order", auditable_id: dest_order.id)
      aud_dest.update_attributes(audited_changes: { 'merge_order' => "Merge order: #{orig_order.order_number} into order: #{dest_order.order_number}"})
    else
      context.fail!
    end
  end
end
