class PaymentSearchPresenter
  include Search::MarketAndOrganization

  attr_reader :organization_id

  def initialize(query: query, user: user)
    @query = query[:q] || {}
    @user = user

    @organization_id = query[:filtered_organization_id].to_s

    if @query[:market_id_eq].present?
      @filtered_market = @user.markets.find(@query[:market_id_eq])
    end
  end
end
