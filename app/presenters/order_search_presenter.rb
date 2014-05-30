class OrderSearchPresenter
  include Search::DateFormat

  attr_reader :start_date, :end_date

  def initialize(query, user)
    @query = query[:q] || {}
    @user = user

    @start_date = format_date(@query[:placed_at_date_gteq])
    @end_date = format_date(@query[:placed_at_date_lteq])
  end

  def market_id
    query[:market_id_eq].to_s
  end

  def organization_id
    query[:organization_id_eq].to_s
  end

  def selling_markets
    @user.managed_markets.order(:name)
  end

  def buyer_organizations
    Order.orders_for_seller(@user).joins(:organization).map(&:organization).uniq
  end
end
