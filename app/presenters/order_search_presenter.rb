class OrderSearchPresenter
  include Search::DateFormat
  include Search::MarketAndOrganization

  attr_reader :start_date, :end_date

  def initialize(query, user)
    @query = query[:q] || {}
    @filtered_market = @query[:market_id_eq]

    @user = user

    @start_date = format_date(@query[:placed_at_date_gteq])
    @end_date = format_date(@query[:placed_at_date_lteq])
  end
end
