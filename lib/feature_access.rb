require 'constructor_struct'

class FeatureAccess
  def self.order_printables?(user:, order:)
    market = order.market
    user_belongs_to_market = user.markets.include?(market)
    user_organization_bought_order = user.organizations.include?(order.organization)
    can_view = (user.admin? or (user_belongs_to_market and market.plan.order_printables and (user.can_manage_market?(market) or user_organization_bought_order)))
  end

  def self.packing_labels?(user_delivery_context:)
    return true if user_delivery_context.is_admin

    return (user_delivery_context.has_feature(:order_printables) and (user_delivery_context.is_seller or user_delivery_context.is_market_manager))
  end

  def self.build_delivery_context(user:, delivery:)
    delivery_market = delivery.delivery_schedule.market
    available_features = delivery_market.plan.attributes.map{|attribute, value| attribute.to_sym if value == true}.compact
    is_market_manager = user.managed_markets.include?(delivery_market)
    is_seller = false
    delivery.orders.each do |order|
      order.items.each{|item| is_seller = true if user.organizations.include?(item.seller)}
    end
    is_buyer_only = (user.buyer_only?)
    is_admin = user.admin?
    UserDeliveryContext.new(available_features: available_features, is_market_manager: is_market_manager, is_seller: is_seller, is_buyer_only: is_buyer_only, is_admin: is_admin)
  end

  UserDeliveryContext = ConstructorStruct.new(
    :available_features,
    :is_market_manager,
    :is_seller,
    :is_buyer_only,
    :is_admin
  ) do

    def has_feature(sym)
      available_features.include?(sym)
    end
  end
end
>>>>>>> feature/avery-labels
