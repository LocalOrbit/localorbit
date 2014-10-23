class FeatureAccess
  def self.order_printables?(user:, order:)
    market = order.market
    user_belongs_to_market = user.markets.include?(market)
    user_organization_bought_order = user.organizations.include?(order.organization)
    can_view = (user.admin? or (user_belongs_to_market and market.plan.order_printables and (user.can_manage_market?(market) or user_organization_bought_order)))
  end
end