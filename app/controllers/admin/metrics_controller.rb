class Admin::MetricsController < AdminController
  before_action :require_admin

  def index
    redirect_to admin_metric_path("financials")
  end

  def show
    @presenter = MetricsPresenter.metrics_for(
      groups: [params[:id]],
      interval: params[:interval],
      markets: params[:market],
      start_date: params[:start_date].try(:to_date),
      end_date: params[:end_date].try(:to_date))
    render_404 unless @presenter
  end

  def map
    # @mapbox_map_id = ENV.fetch('MAPBOX_API_KEY')
    # markets = Market.where.not(id: Metrics::Base::TEST_MARKET_IDS).all.
    #            joins("LEFT JOIN market_addresses ON (market_addresses.market_id = markets.id) AND (market_addresses.id = (SELECT market_addresses.id FROM market_addresses WHERE market_addresses.market_id = markets.id AND market_addresses.deleted_at IS NULL ORDER BY created_at ASC LIMIT 1))").
    #            joins("INNER JOIN geocodings ON geocodings.geocodable_type = 'MarketAddress' AND geocodings.geocodable_id = market_addresses.id").
    #            includes({organization: :plan}, addresses: [:geocoding])
    # @map_data = ActiveModel::ArraySerializer.new(markets, each_serializer: MarketMapSerializer).to_json
    # @plans = plans_with_slugs
  end

  private

  def plans_with_slugs
    Plan.all.map {|plan| {name: plan.name, slug: plan.name.parameterize.underscore} }
  end
end
