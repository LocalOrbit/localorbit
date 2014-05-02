class MarketManagerOverview < FinancialOverview
  def initialize(opts={})
    super
    @calculation_method = :gross_total
  end
end
