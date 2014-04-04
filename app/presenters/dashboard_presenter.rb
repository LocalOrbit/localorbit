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
    # TODO: Should scope by pending seller payment once payments are implemented
    @pending_orders ||= Order.orders_for_seller(@user).order("placed_at DESC").limit(15)
  end

  def upcoming_deliveries
    @upcoming_deliveries ||= Delivery.upcoming_for_seller(@user).decorate
  end
end