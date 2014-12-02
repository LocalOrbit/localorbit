require 'constructor_struct'
UserDeliveryContext = ConstructorStruct.new(
    :packing_labels_feature,
    :is_market_manager,
    :is_seller,
    :is_buyer_only,
    :is_admin) do

  class << self
    def build(user:, delivery:)
      market = delivery.delivery_schedule.market
      is_market_manager = user.managed_markets.include?(market)
      is_seller = false
      delivery.orders.each do |order|
        order.items.each{|item| is_seller = true if user.organizations.include?(item.seller)}
      end
      is_buyer_only = (user.buyer_only?)
      is_admin = user.admin?

      return self.new(
        packing_labels_feature: !!(market.plan.packing_labels?),
        is_market_manager: is_market_manager, 
        is_seller: is_seller, 
        is_buyer_only: is_buyer_only, 
        is_admin: is_admin
      )
    end
  end
end
