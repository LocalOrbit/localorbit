class PaymentSearchPresenter
  include Search::MarketAndOrganization

  def initialize(query: query, user: user)
    @query = query[:q] || {}
    @user = user

    if @query[:market_id_eq].present?
      @filtered_market = @user.markets.find(@query[:market_id_eq])
    end
  end
end
