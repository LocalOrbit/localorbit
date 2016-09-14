class OrderSearchPresenter
  include Search::DateFormat
  include Search::MarketAndOrganization

  attr_reader :start_date, :end_date, :query
  def initialize(query, user, date_search_attr="invoice_due_date", for_invoice=false)
    @query = Search::QueryDefaults.new(query[:q] || {}, date_search_attr, for_invoice).query
    @user = user

    if @query[:market_id_in].present?
      @filtered_market = @user.markets.find(@query[:market_id_in])
    end

    @start_date = format_date(@query["#{date_search_attr}_date_gteq".to_s])
    @end_date = format_date(@query["#{date_search_attr}_date_lteq".to_s])
  end
end
