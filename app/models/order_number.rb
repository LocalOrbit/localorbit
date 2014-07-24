class OrderNumber
  def initialize(market)
    @market = market
  end

  def id
    @order_number ||= "LO-#{order_namespace}-#{order_id}"
  end

  private

  def order_namespace
    "#{year}-#{market_id}"
  end

  def order_id
    "%07d" % Sequence.increment_for("order-#{order_namespace}")
  end

  def market_id
    @market.ascii_subdomain.upcase
  end

  def year
    Time.now.in_time_zone(@market.timezone).strftime("%y")
  end
end
