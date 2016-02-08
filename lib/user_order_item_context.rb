require 'constructor_struct'
UserOrderItemContext = ConstructorStruct.new(
    :delivery_pending,
    :is_market_manager,
    :is_seller,
    :is_admin,
    :is_localeyes_buyer,
    :sellers_edit_orders_feature) do

  class << self
    def build(user:, order_item:)
      market = order_item.order.market
      is_market_manager = user.managed_markets.include?(market)
      is_seller = user.organizations.include?(order_item.seller)
      is_admin = user.admin?
      is_localeyes_buyer = user.is_localeyes_buyer?
      delivery_pending = order_item.delivery_status == 'pending'
      sellers_edit_orders_feature = !!(market.organization.plan.try(:sellers_edit_orders)) && market.sellers_edit_orders

      return self.new(
        is_market_manager: is_market_manager,
        is_seller: is_seller,
        is_admin: is_admin,
        delivery_pending: delivery_pending,
        is_localeyes_buyer: is_localeyes_buyer,
        sellers_edit_orders_feature: sellers_edit_orders_feature
      )
    end
  end
end
