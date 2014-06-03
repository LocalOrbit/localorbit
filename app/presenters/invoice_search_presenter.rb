class InvoiceSearchPresenter
  include Search::DateFormat
  include Search::MarketAndOrganization

  attr_reader :start_date, :end_date
  def initialize(query, user)
    @query = query[:q] || {}
    @user = user

    if @query[:market_id_eq].present?
      @filtered_market = @user.markets.find(@query[:market_id_eq])
    end

  end
end
