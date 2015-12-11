class BuyerOrderPresenter
  include Search::DateFormat
  include Search::MarketAndOrganization

  attr_reader :start_date, :end_date, :query
  def initialize(user, market, request_params={}, query=nil)
    @user   = user
    @market = market
    @request_params = request_params
    @query = Search::QueryDefaults.new(query[:q] || {}, 'placed_at').query

    @start_date = format_date(@query["placed_at_date_gteq".to_s])
    @end_date = format_date(@query["placed_at_date_lteq".to_s])
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

  def pending_orders
    # TODO: Should scope by pending seller payment once payments are implemented
    @pending_orders ||= Order.orders_for_seller(@user).periscope(@request_params).order("placed_at DESC").limit(15)
  end

  def upcoming_deliveries
    @upcoming_deliveries ||= @market.upcoming_deliveries_for_user(@user).periscope(@request_params).decorate
  end
end
