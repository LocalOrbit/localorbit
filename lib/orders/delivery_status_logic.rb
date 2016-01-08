module Orders
  class DeliveryStatusLogic
    class << self
      ValidDeliveryStatuses = OrderItem::DELIVERY_STATUSES

      # Delivered: All items are Delivered (perhaps some canceled)
      # Pending: All items are Pending (perhaps some canceled)
      # canceled: All items canceled
      # Partially Delivered: Some items Delivered, some items Pending (perhaps some canceled)
      # Contested: One or more items are Contested
      # Contested, Partially Delivered: Some items Contested, some items Delivered, some items Pending
      def overall_status(statuses)
        items = ValidDeliveryStatuses & statuses.map(&:to_s).map(&:downcase).uniq
        
        if items.length == 1
          return items.first 
        end

        items -= ["canceled"]
        if items.length == 1
          return items.first 
        end

        partial = %w(pending delivered)
        if partial == (partial & items)
          return 'partially delivered'
        end

        return "unknown"
      end

      def human_readable(status)
        status.to_s.titleize
      end

      def overall_status_for_order(order)
        overall_status order.items.map(&:delivery_status)
      end
    end
  end
end
