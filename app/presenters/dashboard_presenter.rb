class DashboardPresenter
  def initialize(user, market)
    @user   = user
    @market = market
  end

  def template
    if @user.admin?
      "admin"
    elsif @user.market_manager?
      "market_manager"
    elsif @user.seller?
      "seller"
    else
      "buyer"
    end
  end

  def buyer_orders
    @buyer_orders ||= Order.orders_for_buyer(@user).order("placed_at DESC").limit(25)
  end

  def pending_orders
    # TODO: Should scope by pending seller payment once payments are implemented
    @pending_orders ||= Order.orders_for_seller(@user).order("placed_at DESC").limit(15)
  end

  def upcoming_deliveries
    @upcoming_deliveries ||= @market.upcoming_deliveries_for_user(@user).decorate
  end
end