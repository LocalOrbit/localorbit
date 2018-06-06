class Order::DeliveryStatusPolicy

  def initialize(user, order)
    @user = user
    @order = order
  end

  def mark_delivered?
    return false if user.buyer_only?
    return false unless order.undelivered_for_user?(user)
    user.can_manage_market?(order.market) || delivery_schedule_is_direct_to_customer?
  end

  def mark_undelivered?
    (order.market.is_buysell_market? && !order.undelivered_for_user?(user) && user.can_manage_market?(order.market)) ||
      (order.market.is_consignment_market? && user.can_manage_market?(order.market) &&
        (order.delivery_status == 'delivered' || order.delivery_status == 'partially delivered') && Inventory::Utils.consignment_can_undeliver?(order))
  end

  private

  attr_reader :user, :order

  def delivery_schedule_is_direct_to_customer?
    order.delivery.delivery_schedule.direct_to_customer?
  end

end