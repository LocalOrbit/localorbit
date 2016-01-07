module Orders
  class SellerItems
    class << self
      def items_for_seller(order, user)
        organization_ids = user.managed_organizations.map(&:id)
        if user.admin? || user.market_manager?
          OrderItem
        else
          OrderItem.joins(:product).where(order: order, products: {organization_id: organization_ids})
        end
      end
    end
  end
end