module Orders
  # FIXME: Consolidate like methods.
  class OrderItems
    class << self
      def items_for_seller(order, user)
        organization_ids = user.managed_organizations.map(&:id)
        # FIXME: How is this method for seller but it checks for admin or manager here?!
        if user.admin? || user.market_manager?
          OrderItem
        else
          OrderItem.joins(:product).where(order: order, products: {organization_id: organization_ids})
        end
      end

      def find_order_items(order_ids, user)
        where_options = { order_id: order_ids }

        if !user.admin? && !user.market_manager?
          where_options[:products] = { organization_id: user.managed_organization_ids_including_deleted }
        end

        OrderItem.includes({order: :delivery}).joins(:product).where(where_options)
      end
    end
  end
end
