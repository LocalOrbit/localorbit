class PaymentSearchPresenter
  include Search::MarketAndOrganization
  include Search::DateFormat

  attr_reader :organization_id, :start_date, :end_date

  def initialize(query: query, user: user)
    date_search_attr = "placed_at"
    @query = Search::QueryDefaults.new(query[:q] || {}, date_search_attr).query
    @user = user

    @organization_id = query[:filtered_organization_id].to_s

    if @query[:market_id_eq].present?
      @filtered_market = @user.markets.find(@query[:market_id_eq])
    end

    @start_date = format_date(@query["#{date_search_attr}_date_gteq".to_s])
    @end_date = format_date(@query["#{date_search_attr}_date_lteq".to_s])
  end

  def payment_statuses
    ["paid", "pending"].map {|v| [v.titleize, v]}
  end
end
