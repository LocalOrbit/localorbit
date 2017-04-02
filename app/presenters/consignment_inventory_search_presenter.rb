class ConsignmentInventorySearchPresenter
  include Search::DateFormat
  include Search::MarketAndOrganization

  attr_reader :start_date, :end_date, :query
  def initialize(query, user, date_search_attr="created_at")
    @query = Search::QueryDefaults.new(query[:q] || {}, date_search_attr).query
    @user = user
  end

  def categories(user, market)
    @categories = Category.select("products.category_id, products.name").joins(:products).where(depth: [1..2], products: {organization_id: user.managed_markets.map {|m| m.organizations.pluck(:id).flatten}}).order("products.name").uniq
  end
end