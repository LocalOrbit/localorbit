class DashboardPresenter
  def initialize(user)
    @user = user
  end

  def template
    if @user.admin?
      "admin"
    elsif @user.market_manager?
      "market_manager"
    elsif @user.seller?
      "seller"
    end
  end

  def pending_orders
    @pending_orders ||= Order.orders_for_seller(@user).order("placed_at DESC").pending
  end

  def upcoming_deliveries
    @upcoming_deliveries ||= Delivery.for_seller().upcoming
  end
end