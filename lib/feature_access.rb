
class FeatureAccess
  def self.order_printables?(user:, order:)
    market = order.market
    user_belongs_to_market = user.markets.include?(market)
    user_organization_bought_order = user.organizations.include?(order.organization)
    can_view = (user.admin? or (user_belongs_to_market and market.plan.order_printables and (user.can_manage_market?(market) or user_organization_bought_order)))
  end

  def self.packing_labels?(user_delivery_context:)
    return true if user_delivery_context.is_admin

    return (user_delivery_context.has_feature(:packing_labels) and (user_delivery_context.is_seller or user_delivery_context.is_market_manager))
  end

  def self.master_packing_slips?(user_delivery_context:)
    (user_delivery_context.is_admin or user_delivery_context.is_market_manager)
  end
end
