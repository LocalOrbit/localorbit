class SellerOverview < FinancialOverview
  def initialize(opts={})
    super
    @calculation_method = :seller_net_total
  end
end
