
class FeatureAccess
  class << self
    def order_templates?(market:)
      market.plan.name == "LocalEyes"
    end

    def can_edit_order?(user:, order:)
      return (user.admin? || user.managed_markets.include?(order.market))
    end

    def order_printables?(user:, order:)
      market = order.market
      user_belongs_to_market = user.markets.include?(market)
      user_organization_bought_order = user.organizations.include?(order.organization)
      can_view = (user.admin? or (user_belongs_to_market and market.plan.order_printables and (user.can_manage_market?(market) or user_organization_bought_order)))
    end

    def packing_labels?(user_delivery_context:)
      return true if user_delivery_context.is_admin

      return (user_delivery_context.packing_labels_feature and (user_delivery_context.is_seller or user_delivery_context.is_market_manager))
    end

    def master_packing_slips?(user_delivery_context:)
      (user_delivery_context.is_admin or user_delivery_context.is_market_manager)
    end

    def edit_ordered_quantity?(user_order_item_context:)
      return false if !user_order_item_context.delivery_pending
      edit_order_stuff?(user_order_item_context)
    end

    def edit_delivered_quantity?(user_order_item_context:)
      edit_order_stuff?(user_order_item_context)
    end

    def delete_order_item?(user_order_item_context:)
      return false if !user_order_item_context.delivery_pending
      edit_order_stuff?(user_order_item_context)
    end

    def order_action_links?(user_order_context:)
      edit_order_stuff?(user_order_context)
    end

    def add_order_items?(user_order_context:)
      edit_order_stuff?(user_order_context)
    end

    def sellers_edit_orders_feature_available?(market:)
      !!market.plan.try(:sellers_edit_orders?)
    end

    def has_procurement_managers?(market:)
      !!market.plan.try(:has_procurement_managers?)
    end

    def product_level_fee?(market:)
      !!market.try(:allow_product_fee?)
    end

    private
    def edit_order_stuff?(context)
      return true if context.is_admin
      return true if context.is_market_manager
      return true if context.is_seller && context.sellers_edit_orders_feature
      return true if context.is_localeyes_buyer
      false
    end
  end
end
