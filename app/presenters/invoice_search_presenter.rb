class InvoiceSearchPresenter
  include Search::DateFormat
  include Search::MarketAndOrganization

  attr_reader :start_date, :end_date
  def initialize(query, user, date_search_attr="invoice_due_date")
    @query = query[:q] || {}
    @user = user

    if @query[:market_id_eq].present?
      @filtered_market = @user.markets.find(@query[:market_id_eq])
    end

    @start_date = format_date(@query["#{date_search_attr}_date_gteq".to_s])
    @end_date = format_date(@query["#{date_search_attr}_date_lteq".to_s])
  end
end
