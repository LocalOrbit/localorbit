class OrderNumber
  def initialize(market)
    @market = market
  end

  def id
    @order_number ||= "LO-#{order_namespace}-#{order_id}"
  end
  
  def self.relinquish(order_number)
    order_string = (order_number.instance_of? String) ? order_number : order_number.order_number
    order_without_LO = order_string.partition('LO-').last
    partitioned_order = order_without_LO.rpartition('-')
    name = partitioned_order.first
    order_id = partitioned_order.last
    Sequence.decrement_for("order-#{name}", order_id)
  end

  private

  def order_namespace
    "#{year}-#{market_id}"
  end

  def order_id
    "%07d" % Sequence.increment_for("order-#{order_namespace}")
  end

  def market_id
    @market.subdomain.upcase
  end

  def year
    Time.now.in_time_zone(@market.timezone).strftime("%y")
  end
end
