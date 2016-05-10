require 'constructor_struct'
UserOrderContext = ConstructorStruct.new(
    :sellers_edit_orders_feature,
    :is_market_manager,
    :is_seller,
    :seller_organization,
    :is_admin,
    :is_localeyes_buyer) do

  class << self
    def build(user:, order:)
      market = order.market
      is_market_manager = user.managed_markets.include?(market)

      seller_organization = nil
      order.items.each do |order_item|
        if user.organizations.include?(order_item.seller)
          seller_organization = order_item.seller
          break
        end
      end

      is_seller = !seller_organization.nil?
      is_admin = user.admin?
      is_localeyes_buyer = user.is_localeyes_buyer?
      sellers_edit_orders_feature = !!(market.organization.plan.try(:sellers_edit_orders)) && market.sellers_edit_orders

      return self.new(
        is_market_manager: is_market_manager,
        seller_organization: seller_organization,
        is_seller: is_seller,
        is_admin: is_admin,
        is_localeyes_buyer: is_localeyes_buyer,
        sellers_edit_orders_feature: sellers_edit_orders_feature
      )
    end
  end
end
